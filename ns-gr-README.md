# Tout
## Lister mes namespace K8S
```
sudo kubectl get namespaces
```
## Afficher mes liées au namespace ns-gr K8S
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
    ```bash
    sudo kubectl apply -f serviceAccount_Role_RoleBiding_RBAC.yaml
    sudo kubectl apply -f serviceAccount_Role_RoleBiding_RBAC.yaml
    sudo kubectl apply -f serviceAccount_Role_RoleBiding_RBAC.yaml
    ```

  * Ou bien, utiliser le fichier cobiné qui contient les diffèrent manifests précédents:
    * [le fichier combiné ](ServiceAccountRBAC/ serviceAccount_Role_RoleBiding_RBAC.yaml)

    ```bash
    sudo kubectl apply -f serviceAccount_Role_RoleBiding_RBAC.yaml
    ```
![Description de l'image](assets/image1.png)
