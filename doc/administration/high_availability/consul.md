# Working with the bundled Consul service **(PREMIUM ONLY)**

## Overview

As part of its High Availability stack, GitLab Premium includes a bundled version of [Consul](https://www.consul.io/) that can be managed through `/etc/gitlab/gitlab.rb`.

A Consul cluster consists of multiple server agents, as well as client agents that run on other nodes which need to talk to the consul cluster.

## Prerequisites

First, make sure to [download/install](https://about.gitlab.com/install/)
GitLab Omnibus **on each node**.

Choose an installation method, then make sure you complete steps:

1. Install and configure the necessary dependencies.
1. Add the GitLab package repository and install the package.

When installing the GitLab package, do not supply `EXTERNAL_URL` value.

## Configuring the Consul nodes

On each Consul node perform the following:

1. Make sure you collect [`CONSUL_SERVER_NODES`](database.md#consul-information), which are the IP addresses or DNS records of the Consul server nodes, for the next step, before executing the next step.

1. Edit `/etc/gitlab/gitlab.rb` replacing values noted in the `# START user configuration` section:

    ```ruby
    # Disable all components except Consul
    roles ['consul_role']

    # START user configuration
    # Replace placeholders:
    #
    # Y.Y.Y.Y consul1.gitlab.example.com Z.Z.Z.Z
    # with the addresses gathered for CONSUL_SERVER_NODES
    consul['configuration'] = {
      server: true,
      retry_join: %w(Y.Y.Y.Y consul1.gitlab.example.com Z.Z.Z.Z)
    }

    # Disable auto migrations
    gitlab_rails['auto_migrate'] = false
    #
    # END user configuration
    ```

    > `consul_role` was introduced with GitLab 10.3

1. [Reconfigure GitLab](../restart_gitlab.md#omnibus-gitlab-reconfigure) for the changes
   to take effect.

### Consul checkpoint

Before moving on, make sure Consul is configured correctly. Run the following
command to verify all server nodes are communicating:

```sh
/opt/gitlab/embedded/bin/consul members
```

The output should be similar to:

```
Node                 Address               Status  Type    Build  Protocol  DC
CONSUL_NODE_ONE      XXX.XXX.XXX.YYY:8301  alive   server  0.9.2  2         gitlab_consul
CONSUL_NODE_TWO      XXX.XXX.XXX.YYY:8301  alive   server  0.9.2  2         gitlab_consul
CONSUL_NODE_THREE    XXX.XXX.XXX.YYY:8301  alive   server  0.9.2  2         gitlab_consul
```

If any of the nodes isn't `alive` or if any of the three nodes are missing,
check the [Troubleshooting section](#troubleshooting) before proceeding.

## Operations

### Checking cluster membership

To see which nodes are part of the cluster, run the following on any member in the cluster
```
# /opt/gitlab/embedded/bin/consul members
Node            Address               Status  Type    Build  Protocol  DC
consul-b        XX.XX.X.Y:8301        alive   server  0.9.0  2         gitlab_consul
consul-c        XX.XX.X.Y:8301        alive   server  0.9.0  2         gitlab_consul
consul-c        XX.XX.X.Y:8301        alive   server  0.9.0  2         gitlab_consul
db-a            XX.XX.X.Y:8301        alive   client  0.9.0  2         gitlab_consul
db-b            XX.XX.X.Y:8301        alive   client  0.9.0  2         gitlab_consul
```

Ideally all nodes will have a `Status` of `alive`.

### Restarting the server cluster

**Note**: This section only applies to server agents. It is safe to restart client agents whenever needed.

If it is necessary to restart the server cluster, it is important to do this in a controlled fashion in order to maintain quorum. If quorum is lost, you will need to follow the consul [outage recovery](#outage-recovery) process to recover the cluster.

To be safe, we recommend you only restart one server agent at a time to ensure the cluster remains intact.

For larger clusters, it is possible to restart multiple agents at a time. See the [Consul consensus document](https://www.consul.io/docs/internals/consensus.html#deployment-table) for how many failures it can tolerate. This will be the number of simulateneous restarts it can sustain.

## Troubleshooting

### Consul server agents unable to communicate

By default, the server agents will attempt to [bind](https://www.consul.io/docs/agent/options.html#_bind) to '0.0.0.0', but they will advertise the first private IP address on the node for other agents to communicate with them. If the other nodes cannot communicate with a node on this address, then the cluster will have a failed status.

You will see messages like the following in `gitlab-ctl tail consul` output if you are running into this issue:

```
2017-09-25_19:53:39.90821     2017/09/25 19:53:39 [WARN] raft: no known peers, aborting election
2017-09-25_19:53:41.74356     2017/09/25 19:53:41 [ERR] agent: failed to sync remote state: No cluster leader
```


To fix this:

1. Pick an address on each node that all of the other nodes can reach this node through.
1. Update your `/etc/gitlab/gitlab.rb`

    ```ruby
    consul['configuration'] = {
      ...
      bind_addr: 'IP ADDRESS'
    }
    ```
1. Run `gitlab-ctl reconfigure`

If you still see the errors, you may have to [erase the consul database and reinitialize](#recreate-from-scratch) on the affected node.

### Consul agents do not start - Multiple private IPs

In the case that a node has multiple private IPs the agent be confused as to which of the private addresses to advertise, and then immediately exit on start.

You will see messages like the following in `gitlab-ctl tail consul` output if you are running into this issue:

```
2017-11-09_17:41:45.52876 ==> Starting Consul agent...
2017-11-09_17:41:45.53057 ==> Error creating agent: Failed to get advertise address: Multiple private IPs found. Please configure one.
```

To fix this:

1. Pick an address on the node that all of the other nodes can reach this node through.
1. Update your `/etc/gitlab/gitlab.rb`

    ```ruby
    consul['configuration'] = {
      ...
      bind_addr: 'IP ADDRESS'
    }
    ```
1. Run `gitlab-ctl reconfigure`

### Outage recovery

If you lost enough server agents in the cluster to break quorum, then the cluster is considered failed, and it will not function without manual intervenetion.

#### Recreate from scratch
By default, GitLab does not store anything in the consul cluster that cannot be recreated. To erase the consul database and reinitialize

```
# gitlab-ctl stop consul
# rm -rf /var/opt/gitlab/consul/data
# gitlab-ctl start consul
```

After this, the cluster should start back up, and the server agents rejoin. Shortly after that, the client agents should rejoin as well.

#### Recover a failed cluster
If you have taken advantage of consul to store other data, and want to restore the failed cluster, please follow the [Consul guide](https://www.consul.io/docs/guides/outage.html) to recover a failed cluster.
