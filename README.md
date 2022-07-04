Filters here are not thoroughly tested, consider them unsafe.
These are for my homelab thinkering, use at your own peril.

## How to use?

(Tested on Fedora 36 Server Edition)

The `redifine-nwfilters.sh` script takes one argument which is the directory to recursively find and define filters.
```shell
sudo src/redefine-nwfilters.sh src/nwfilters
```

Having imported filters, add filterref to a VM. Sample: `src/filterref-template.xml`. Note that its content must be embedded into a NIC's `<interface>` block.

E.g:
```
<interface type='network'>
	<filterref filter='homelab-isolation'>
		...
	</filterref>
</interface>
```

---

## About script

Summary:
* Script requires use of sudo or a user with appropiate priveledges/groups to manage libvirt.
* Filename must conform to `nwfilter-*.xml`.
* Filter's name is parsed from its file.
* Redefine in this context means to destroy/undefine and define afterwards

Shortcomings:
* If you change filter name, the script will not account for it. The previous filter must be deleted manually.
* If filters are in use, the domain (VM) using it must be shut down. (Not a hard requirement of libvirt)

## About filters

### Subnets

Three types of rules are used in a hierarchy to provide granulization.
```
DROP > ACCEPT > REJECT
```

This order makes it possible to:
1. Black-out a wide range of subnets with `reject`
2. Then to allow known subnets by `accept`
3. Lastly override them in any case with `drop`

A rough approach, but works for my simple case.

### Ports

Ports follow the same mantra as subnets. However, due to unused parameter errors, I had to comment out port "filterref"s except for `port-out-reject`, which is used for blocking ports 0-1023 and 9090 (Cockpit) on gateway (a.k.a. hypervisor) to the guest machine.
