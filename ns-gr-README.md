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
## Ajouter mon certificat gitlab self-signed à un secret sous le namespace ns-gr K8S
### Existant
```
saber@optiplex3060:/etc/gitlab/ssl$ ll gitlab.*
-rw-r--r-- 1 root root  245 mars  22 16:38 gitlab.cnf
-rw-r--r-- 1 root root 1082 mars  22 16:44 gitlab.crt
-rw-r--r-- 1 root root  903 mars  22 16:43 gitlab.csr
-rw------- 1 root root 1708 mars  22 16:43 gitlab.key
saber@optiplex3060:/etc/gitlab/ssl$ cat gitlab.cnf
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
* CN = gitlab.optiplex3060 → Le nom commun (CN) du certificat est gitlab.optiplex3060.
* subjectAltName (SAN) → Cette section ajoute deux éléments :
    * IP.1 = 192.168.1.76
    * DNS.1 = gitlab.optiplex3060
### Ajout et vérification
```sh
sudo kubectl create secret generic gitlab-tls --from-file=gitlab.crt=/etc/gitlab/ssl/gitlab.crt -n ns-gr

```

```yml 
apiVersion: v1
kind: ConfigMap
metadata:
  name: gitlab-ca-cert
  namespace: ns-gr  # Remplace avec le namespace approprié
data:
  gitlab.crt: |
    -----BEGIN CERTIFICATE-----
    MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...
    -----END CERTIFICATE-----

```
## Créer mon namespace ns-gr comme namaspace gitlab-runner
```
sudo kubectl create namespace ns-gr
```
