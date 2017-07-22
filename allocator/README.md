# Huge Page allocator

This is a recipe for allocating Huge Pages in a Kubernetes cluster.

It is deployed as a daemonset on the nodes where you want to allocate huge pages
for use by applications on the cluster.

To use the application, you can do the following:

```shell
kubectl create -f https://raw.githubusercontent.com/derekwaynecarr/hugepages/master/allocator/daemonset.yaml
```

This allocator does the following:

1. Attempts to allocate the specified number of 2MB huge pages
1. Restarts kubelet to pick up any changes (to pick-up the change to resources)
1. Sleeps forever (DaemonSets do not support run to completion)

Run `kubectl describe nodes` to view resource `Capacity` for Kubernetes nodes.