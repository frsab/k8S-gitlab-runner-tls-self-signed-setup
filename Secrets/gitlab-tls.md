# Mise en place d'un certificat self-signed GitLab pour les pods Kubernetes
## Contexte
Dans un environnement Kubernetes,j'ai un certificat GitLab auto-signé situé sur /etc/gitlab/ssl/gitlab.crt. Ce certificat doit être mis à disposition des pods Kubernetes pour permettre une connexion HTTPS sécurisée.

## Création de secret gitlab-tls
Le secret gitlab-tls va encapsuler notre certificat gitlab situé sur l'url "/etc/gitlab/ssl/gitlab.crt"

```sh
sudo kubectl create secret generic gitlab-tls --from-file=gitlab.crt=/etc/gitlab/ssl/gitlab.crt -n ns-gr

```
### Explication de la commande
kubectl create secret generic : Crée un secret générique.

gitlab-tls : Nom du secret.

--from-file=gitlab.crt=/etc/gitlab/ssl/gitlab.crt : Indique le fichier à ajouter au secret.

-n ns-gr : Spécifie le namespace (ns-gr).

## Vérification de secret gitlab-tls créé
Pour vérifier le bon fonctionnement de secret et le certificat qui es dedans, je mets en place un pod de debug et dans lequel je passe la commande suivant : 
```sh
curl -v --cacert ./gitlab.crt https://gitlab.optiplex3060:9988/
```
Voici, un chapitre qui explique le DEBUG et validation de secret [En savoir plus sur le debug fait...](debug-test/debug-test.md)

## Modification de /etc/hosts dans les pods
Dans certains cas, il est nécessaire d'ajouter des entrées spécifiques dans le fichier /etc/hosts des pods , par exemple pour résoudre un nom d'hôte interne non résolu par le DNS de Kubernetes.

Exemple d'ajout dans un pod
Pour ajouter des entrées dans le fichier /etc/hosts, vous pouvez utiliser un hostAliases dans la définition du pod, comme suit ([test-pod-with-hostAliases](debug-test/test-pod-with-hostAliases.yaml)).

Dans mon cas, j'ai utilisé un ConfigMap pour stocker les entrées de /etc/hosts, puis j'ai monté ce ConfigMap dans le pod sous forme de fichier.

Cela signifie que le fichier /etc/hosts du pod n’a pas été modifié directement. À la place, j'ai injecté un fichier contenant nos entrées d’hôte personnalisées, qui peut être lu par les conteneurs du pod comme l'exemple suivant .
* Volume :[le fichier configMaps/custom-hosts](../configMaps/custom-hosts.yml) et [Définition du volume pour le certificat ](debug-test/test-pod.yaml#L29-L31)
* Montage de volume : [Montage des hosts](debug-test/test-pod.yaml#L18-L20)


Contrairement à hostAliases, cette méthode nous permet de centraliser la gestion des entrées hosts via un ConfigMap, ce qui peut être utile pour des mises à jour dynamiques sans modifier le manifeste du pod.

