<details>

<summary>Filtrar pods pelo status</summary>

```sh
kubectl get pods --field-selector=status.phase=Running
# Status: Pending, Running, Succeeded, Unknown, Failed
```

</details>

<details>

<summary>Node Requests com AWK</summary>

```sh
kubectl describe nodes | awk '
/^Name:/ { block=$0; next}
/^Allocated resources:/ {print block; print; c=8; next}
c > 0 {print; c--}
'
```

</details>

<details>

<summary>Pegar taints com jq</summary>

```sh
 #Pegar em formato texto - output curto
 kubectl get nodes -o json | jq -r '.items[] | "\(.metadata.name)\t\(.spec.taints // "[]")"'
 #Pegar em formato json - Output Longo
 kubectl get nodes -o json | jq  '[ .items[] | {name: .metadata.name,Taints: (.spec.taints // {})}]'
```

</details>

<details>

<summary>Pegar tolerations com jq</summary>

```sh
#Pegar em formato texto - Output curto
kubectl get pods --field-selector=status.phase=Running -o json | jq -r '.items[] |  "\(.metadata.name)\t\(.spec.tolerations // "[]")\n"'
# Pegar em formato json - Output Longo
kubectl get pods --field-selector=status.phase=Running -o json | jq  '[.items[] |  {PodName: .metadata.name,Namespace: .metadata.namespace, Tolerations: (.spec.tolerations // {})}]'
```

</details>

<details>

<summary>Pegar tolerations com jq</summary>

```sh
#Formato texto - output curto
kubectl get pods --field-selector=status.phase=Running -o json | jq -r '.items[] | "\(.metadata.name)\t\(.spec.nodeSelector // "[]")\n"'


```

</details>

<details>

<summary>Verificar o affinity dos pods</summary>

```sh
#Formato texto - output curto
kubectl get pods --field-selector=status.phase=Running -o json | jq -r '.items[] | "\(.metadata.name)\t\(.spec.affinity // "[]")\n"'
#Formato Json estruturado - output longo
kubectl get pods --field-selector=status.phase=Running -o json | jq '[.items[] | {name: .metadata.name,affinity: (.spec.affinity // {})}]'


```

</details>
<details>

<summary>Verificar Imagem do pod</summary>

```sh
kubectl get pods --field-selector=status.phase=Running -o json | jq '[.items[] | {name: .metadata.name,container: (.spec.containers[].image // {})}]'
```

</details>

<details>

<summary>Verificar resources dos pods em Running</summary>

```sh
kubectl get pods --field-selector=status.phase=Running -o json | jq '[.items[] | {name: .metadata.name,resources: (.spec.containers[].resources // {})}]'

```

</details>

<details>

<summary>Verificar QoS dos pods</summary>

```sh
k describe pods | awk ' /^Name:/ {block=$0; next} /QoS Class:/ {print block; print; c=0; next} c > 0 {print; c--}'

```

</details>

### Comandos Tshot

<details>

<summary>Client Mysql para conexão ao banco</summary>

```sh
kubectl run mysql-client --image=mysql:5.7 -i --rm --restart=Never -- mysql -h <mysql-service> -u root -p

```

</details>
