# gitlab-tls
## création de secret gitlab-tls
Le secret gitlab-tls va encapsuler notre certificat gitlab situé sur l'url "/etc/gitlab/ssl/gitlab.crt"

```sh
sudo kubectl create secret generic gitlab-tls --from-file=gitlab.crt=/etc/gitlab/ssl/gitlab.crt -n ns-gr

```

* Le fichier manifests Kubernetes "gitlab-tls-debug-pod.yml" nous permettra de monter un pod de test et debug de notre secret "gitlab-tls".
* Ce manifest est appliquer avec la commande suivante :

```sh
 sudo kubectl apply -f gitlab-tls-debug-pod.yml
 sudo kubectl apply -f gitlab-tls-debug-pod-curl-test.yml
```
