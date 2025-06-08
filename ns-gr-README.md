# Tout
## Lister mes namespace K8S
```
sudo kubectl get namespaces
```
## Afficher mes ressources liées au namespace ns-gr K8S
```
sudo kubectl get all -n ns-gr
sudo kubectl get secret,configmap -n ns-gr

```
## Création de certificat gitlab self-signed à un secret sous le namespace ns-gr K8S
### Existant
* Afficher les materiels cryptographiques de mon gitlab :
```sh
saber@optiplex3060:/etc/gitlab/ssl$ ll gitlab.*
-rw-r--r-- 1 root root  245 mars  22 16:38 gitlab.cnf
-rw-r--r-- 1 root root 1082 mars  22 16:44 gitlab.crt
-rw-r--r-- 1 root root  903 mars  22 16:43 gitlab.csr
-rw------- 1 root root 1708 mars  22 16:43 gitlab.key
saber@optiplex3060:/etc/gitlab/ssl$ cat gitlab.cnf
```
* Contenu de fichier gitlab.cnf :
```ini
[ req ]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no

[ req_distinguished_name ]
CN = gitlab.optiplex3060

[ v3_req ]
subjectAltName = @alt_names

[ alt_names ]
IP.1 = 192.168.1.76
DNS.1 = gitlab.optiplex3060

```
* Description de quelques éléments de fichier gitlab.cnf :

  * CN = gitlab.optiplex3060 → Le nom commun (CN) du certificat est gitlab.optiplex3060.
  * subjectAltName (SAN) → Cette section ajoute deux éléments :
      * IP.1 = 192.168.1.76
      * DNS.1 = gitlab.optiplex3060
### Création et vérification
#### Création de certificat numérique (self-signe)
Pour ajouter un certificat numérique, je propose deux façons de faire:
* Avec la creation d'un secret à partir de certificat local:
```sh
sudo kubectl create secret generic gitlab-tls --from-file=gitlab.crt=/etc/gitlab/ssl/gitlab.crt -n ns-gr

```
* Avec la creation d'un ConfigMap  contenant le certificat TLS :
```yml 
apiVersion: v1
kind: ConfigMap
metadata:
  name: gitlab-ca-cert
  namespace: ns-gr  # Remplace avec le namespace approprié
data:
  gitlab.crt: |
    -----BEGIN CERTIFICATE-----
    MIIBItf1hsfts...
    -----END CERTIFICATE-----
  gitlab.key: |
    -----BEGIN PRIVATE KEY-----
    MIIEvAIBADANB...
    -----END PRIVATE KEY-----

```
⚠️ Inconvénient :
* La clé privée ne devrait jamais être stockée dans un ConfigMap, car les ConfigMaps ne sont pas chiffrés dans etcd (la base de données interne de Kubernetes).

* Toute personne avec accès au ConfigMap peut voir la clé privée, ce qui est un gros risque de sécurité 🚨.
* Si le certificat expire ou doit être renouvelé, il faut modifier le ConfigMap

#### Vérification du certificat numérique (self-signe)
Voici une section qui explique ça en détail : [Création et vérification](Secrets/debug-test/debug-test.md)

## Créer mon namespace ns-gr comme *namaspace gitlab-runner*
```
sudo kubectl create namespace ns-gr
```
## Création du ServiceAccount, Role et RoleBinding pour GitLab Runner
Créer un ServiceAccount, un Role et un RoleBinding dans le namespace ns-gr pour attribuer des permissions au GitLab Runner.
  * Pour ça, j'utilise les fichiers manifest suivant :
    1. [ServiceAccount](ServiceAccountRBAC/a_service-account.yaml) 
    2. [Role ](ServiceAccountRBAC/b_role.yaml) 
    3. [Rolebiding](ServiceAccountRBAC/c_role-biding.yaml)

    ```sh
    sudo kubectl apply -f a_service-account.yaml
    sudo kubectl apply -f b_role.yaml
    sudo kubectl apply -f c_role-biding.yaml
    ```

  * Ou bien, utiliser le fichier combiné qui contient les diffèrents manifests précédents:
    * [le fichier combiné ](ServiceAccountRBAC/ serviceAccount_Role_RoleBiding_RBAC.yaml)

    ```sh
    sudo kubectl apply -f serviceAccount_Role_RoleBiding_RBAC.yaml
    ```
![Description de l'image](assets/image1.png)

## Installation et mise à jour de GitLab Runner
```sh
sudo helm install gitlab-runner-release \
  gitlab/gitlab-runner \
  -f ./values0.72.0.yaml \
  -f ./values.overrideWithSecret.yaml \
  -n ns-gr
```
Cette commande plantera si la release existe déjà. Dan ce cas , utiliser la commande suivante pour installation ou mise à jour.

```sh
sudo helm upgrade --install gitlab-runner-release \
  gitlab/gitlab-runner \
  -f ./values0.72.0.yaml \
  -f ./values.overrideWithSecret.yaml \
  -n ns-gr
```

Cette commande installe ou met à jour GitLab Runner dans le cluster Kubernetes, en utilisant le chart officiel gitlab/gitlab-runner de Helm.

  * Si GitLab Runner est déjà installé dans le cluster sous le nom de release gitlab-runner-sab, la commande met à jour l'installation avec les nouvelles configurations.

  * Si GitLab Runner n'est pas encore installé, la commande va l'installer.

Les configurations de base sont fournies dans le fichier values0.72.0.yaml, et les configurations supplémentaires, comme les secrets et personnalisations, sont définies dans le fichier [values.overrideWithSecret.yaml](values.overrideWithSecret.yaml).

Toutes ces ressources seront créées dans le namespace ns-gr.

### Utilisation des fichiers de valeurs :
  * **values0.72.0.yaml :** Ce fichier contient les paramètres par défaut pour le chart, comme la version du GitLab Runner et les configurations de base.

  * **values.overrideWithSecret.yaml :** Ce fichier permet de personnaliser ou de surcharger certains paramètres, notamment les secrets (par exemple, les tokens de GitLab), ou d'autres configurations spécifiques à ton environnement.