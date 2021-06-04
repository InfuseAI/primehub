see https://github.com/airflow-helm/charts/tree/main/charts/airflow


## Install

```
PRIMEHUB_DOMAIN=example.aws.primehub.io PRIMEHUB_SCHEME=https helmfile diff
```

all objects:

```
kubectl -n airflow get all
NAME                                     READY   STATUS    RESTARTS   AGE
pod/airflow-flower-57dd65c9c9-bq6ch      1/1     Running   0          114s
pod/airflow-postgresql-0                 1/1     Running   0          114s
pod/airflow-redis-master-0               1/1     Running   0          114s
pod/airflow-scheduler-5b97ff8cf9-zzd6c   1/1     Running   0          114s
pod/airflow-web-5dd7b465c9-hrthb         1/1     Running   0          114s
pod/airflow-worker-0                     1/1     Running   0          114s

NAME                                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/airflow-flower                ClusterIP   10.152.183.86    <none>        5555/TCP   114s
service/airflow-postgresql            ClusterIP   10.152.183.65    <none>        5432/TCP   114s
service/airflow-postgresql-headless   ClusterIP   None             <none>        5432/TCP   114s
service/airflow-redis-headless        ClusterIP   None             <none>        6379/TCP   114s
service/airflow-redis-master          ClusterIP   10.152.183.187   <none>        6379/TCP   114s
service/airflow-web                   ClusterIP   10.152.183.49    <none>        8080/TCP   114s
service/airflow-worker                ClusterIP   None             <none>        8793/TCP   114s

NAME                                READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/airflow-flower      1/1     1            1           114s
deployment.apps/airflow-scheduler   1/1     1            1           114s
deployment.apps/airflow-web         1/1     1            1           114s

NAME                                           DESIRED   CURRENT   READY   AGE
replicaset.apps/airflow-flower-57dd65c9c9      1         1         1       114s
replicaset.apps/airflow-scheduler-5b97ff8cf9   1         1         1       114s
replicaset.apps/airflow-web-5dd7b465c9         1         1         1       114s

NAME                                    READY   AGE
statefulset.apps/airflow-postgresql     1/1     114s
statefulset.apps/airflow-redis-master   1/1     114s
statefulset.apps/airflow-worker         1/1     114s
```

## TODOs

1. set default resources to all components
1. override `storageClass`
1. override admin user and/or generate random password

## Users

configure [airflow.yaml.gotmpl](airflow.yaml.gotmpl) to set the admin user
