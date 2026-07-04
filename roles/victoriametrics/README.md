victoriametrics
===============

Installs and configures [VictoriaMetrics](https://victoriametrics.com/) in one
of two topologies, selected by a single input variable:

- **single** – one-node VictoriaMetrics (`victoria-metrics-prod`, port `8428`).
- **ha** – the cluster: `vmstorage`, `vminsert`, `vmselect` (plus `vmagent`).

The role downloads the requested release, places the binaries, and installs a
systemd unit for each component. In HA mode each component can be installed on
its own node, picked from the dynamic inventory by EC2 tag.

Traffic flow (HA)
-----------------

![VictoriaMetrics HA traffic flow](../../images/victoriametrics-traffic-flow.svg)

**Write path:** `vmagent` → `vminsert-LB` (load balancer + target group) →
`vminsert-1/2`. Each vminsert connects **directly to every `vmstorage` node**
and, with `replicationFactor=2`, writes each series to 2 of the 3 storage nodes.

**Query path:** `Grafana`/API → `vmselect-LB` → `vmselect-1/2`. Each vmselect
also connects **directly to every `vmstorage` node** and de-duplicates the
replicated samples at query time (`-dedup.minScrapeInterval`).

> The load-balancer + target-group pattern applies only to the stateless
> `vminsert` and `vmselect` tiers. There is **no load balancer in front of
> `vmstorage`** — vminsert/vmselect must address each storage node individually,
> because that is how sharding and replication are determined.

Requirements
------------

- A `vmuser` system user/group (created by the `common` role in this repo).
- Internet access on the target hosts to pull release tarballs from GitHub.
- `amazon.aws` collection for the dynamic inventory (HA on EC2).

Role Variables
--------------

Defined in `defaults/main.yml` (override in `group_vars/all.yml` or `-e`):

| Variable | Default | Description |
|---|---|---|
| `vm_setup_mode` | `single` | `single` or `ha`. Selects topology and which release tarball is downloaded (`-cluster` suffix for HA). |
| `vm_components` | derived from mode | Which component(s) to install on the current host. `single` → `[single]`; `ha` → `[vmstorage, vminsert, vmselect]`. A play can narrow this to e.g. `[vmstorage]` so each tagged node runs only its own service. |
| `vm_version` | `v1.144.0` | Release tag to install. Drives every download URL. |
| `vm_user` / `vm_group` | `vmuser` | OS user/group that owns the binaries and runs the services. |
| `vm_storage_path` | `/var/lib/vmstorage` | Data directory (single node and `vmstorage`). |
| `vm_bin_dir` | `/usr/local/bin` | Where tarballs are unpacked. |
| `vm_storage_nodes` | 3 example IPs | HA only: bare host/IPs of the `vmstorage` nodes that `vminsert`/`vmselect` connect to. In `ha.yml` this is discovered from the inventory automatically. |
| `vm_replication_factor` | `2` | HA durability: write each series to this many distinct `vmstorage` nodes. Must be `<= len(vm_storage_nodes)` (enforced by an assert). |
| `vm_remote_write_url` | cluster vminsert URL | Where `vmagent` remote-writes. |
| `scrape_interval` | `10s` | `vmagent` scrape interval (also used for `vmselect` `-dedup.minScrapeInterval`). |

### Storage durability & failure tolerance

`vmstorage` does not replicate by default — `vminsert` *shards* series across
the storage nodes. Setting `vm_replication_factor` makes `vminsert` write each
series to that many distinct nodes, and `vmselect` de-duplicates the copies at
query time (`-dedup.minScrapeInterval`). With `N` storage nodes you can lose
`vm_replication_factor - 1` of them with **no data loss or query gaps**:

| vmstorage nodes | replicationFactor | tolerates |
|---|---|---|
| 3 | 2 (default) | **1 node down** ✅ |
| 3 | 1 | 0 (a node down loses ~1/3 of recent data) |
| 5 | 3 | 2 nodes down |

The recommended production baseline in this repo is **3 vmstorage + RF 2** —
survives a single node failure with capacity headroom. The role refuses to run
`vminsert` if `vm_replication_factor` exceeds the number of storage nodes.

Ports and binary names are in `vars/main.yml` (`vm_ports`, `vm_binaries`):
single `8428`, vminsert `8480`, vmselect `8481`, vmstorage `8482` (http) with
`8400`/`8401` for vminsert/vmselect connections, vmagent `8429`.

Dynamic inventory (tag-based node selection)
--------------------------------------------

`inventory/aws_ec2.yml` groups running EC2 instances by their **`Role`** tag, so
the inventory group name equals the tag value:

| EC2 tag | Inventory group |
|---|---|
| `Role=vmstorage` | `vmstorage` |
| `Role=vminsert`  | `vminsert`  |
| `Role=vmselect`  | `vmselect`  |
| `Role=vmagent`   | `vmagent`   |

Tag each instance accordingly and the `ha.yml` playbook targets the right group
automatically. `vminsert`/`vmselect` discover the storage nodes' private IPs
from the `vmstorage` group, and `vmagent` remote-writes to the first `vminsert`
node — no IPs are hard-coded.

Example Playbook
----------------

Single node (one EC2 host, via `site.yml`):

    ansible-playbook site.yml -e vm_setup_mode=single -e vm_version=v1.144.0

HA cluster (nodes picked by `Role` tag, via `ha.yml`):

    ansible-playbook ha.yml -e vm_version=v1.144.0

Using the role directly for one component on a host:

    - hosts: vmstorage
      become: true
      vars:
        vm_setup_mode: ha
        vm_components: ["vmstorage"]
      roles:
        - victoriametrics

License
-------

BSD

Author Information
------------------

MyGurukulam – VictoriaMetrics HA setup.
