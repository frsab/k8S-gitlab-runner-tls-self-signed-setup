# gitlab-tls
## création de secret gitlab-tls
Le secret gitlab-tls va encapsuler notre certificat gitlab situé sur l'url "/etc/gitlab/ssl/gitlab.crt"

```sh
sudo kubectl create secret generic gitlab-tls --from-file=gitlab.crt=/etc/gitlab/ssl/gitlab.crt -n ns-gr

```

* Le fichier manifests Kubernetes "gitlab-tls-debug-pod.yml" nous permettra de monter un pod de test et debug de notre secret "gitlab-tls".
* Ce manifest est appliquer avec la commande suivante :

```sh
 sudo kubectl apply -f test-pod.yml
```
* Sur l'image que j'utilisais, il n'ya pas de curl installé par défaut. Donc, il a fallu l'installer avec les commande suivante :
    * exécuter une commande interactive dans le pod 
    ```sh
    kubectl exec -it test-pod -n ns-gr -- sh
    ```
    Nous sommes en session interactive dans le pod, nous vérifions la version de notre image et installer curl  :

    ```sh
    / #  curl -v --cacert /etc/gitlab-tls/gitlab.crt https://gitlab.optiplex3060:9988/
    sh: curl: not found
    / # cat /etc/os-release
    NAME="Alpine Linux"
    ID=alpine
    VERSION_ID=3.21.3
    PRETTY_NAME="Alpine Linux v3.21"
    HOME_URL="https://alpinelinux.org/"
    BUG_REPORT_URL="https://gitlab.alpinelinux.org/alpine/aports/-/issues"
    / # apk add --no-cache curl
    fetch https://dl-cdn.alpinelinux.org/alpine/v3.21/main/x86_64/APKINDEX.tar.gz
    fetch https://dl-cdn.alpinelinux.org/alpine/v3.21/community/x86_64/APKINDEX.tar.gz
    (1/9) Installing brotli-libs (1.1.0-r2)
    (2/9) Installing c-ares (1.34.3-r0)
    (3/9) Installing libunistring (1.2-r0)
    (4/9) Installing libidn2 (2.3.7-r0)
    (5/9) Installing nghttp2-libs (1.64.0-r0)
    (6/9) Installing libpsl (0.21.5-r3)
    (7/9) Installing zstd-libs (1.5.6-r2)
    (8/9) Installing libcurl (8.12.1-r1)
    (9/9) Installing curl (8.12.1-r1)
    Executing busybox-1.37.0-r12.trigger
    OK: 12 MiB in 24 packages
     ```
    * Maintenant, curl est installé sur notre pod, on lance notre curl pour vérifier la connectivité :
    
    ```sh
    / # curl -v --cacert /etc/gitlab-tls/gitlab.crt https://gitlab.optiplex3060:9988/
    * Host gitlab.optiplex3060:9988 was resolved.
    * IPv6: (none)
    * IPv4: 192.168.1.76
    *   Trying 192.168.1.76:9988...
    * ALPN: curl offers h2,http/1.1
    * TLSv1.3 (OUT), TLS handshake, Client hello (1):
    *  CAfile: /etc/gitlab-tls/gitlab.crt
    *  CApath: /etc/ssl/certs
    * TLSv1.3 (IN), TLS handshake, Server hello (2):
    * TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
    * TLSv1.3 (IN), TLS handshake, Certificate (11):
    * TLSv1.3 (IN), TLS handshake, CERT verify (15):
    * TLSv1.3 (IN), TLS handshake, Finished (20):
    * TLSv1.3 (OUT), TLS change cipher, Change cipher spec (1):
    * TLSv1.3 (OUT), TLS handshake, Finished (20):
    * SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384 / x25519 / RSASSA-PSS
    * ALPN: server accepted h2
    * Server certificate:
    *  subject: CN=gitlab.optiplex3060
    *  start date: Mar 22 15:44:31 2025 GMT
    *  expire date: Mar 20 15:44:31 2035 GMT
    *  subjectAltName: host gitlab.optiplex3060 matched cert s gitlab.optiplex3060
    *  issuer: CN=gitlab.optiplex3060
    *  SSL certificate verify ok.
    *   Certificate level 0: Public key type RSA (2048/112 Bits/secBits), signed using sha256WithRSAEncryption
    * Connected to gitlab.optiplex3060 (192.168.1.76) port 9988
    * using HTTP/2
    * [HTTP/2] [1] OPENED stream for https://gitlab.optiplex3060:9988/
    * [HTTP/2] [1] [:method: GET]
    * [HTTP/2] [1] [:scheme: https]
    * [HTTP/2] [1] [:authority: gitlab.optiplex3060:9988]
    * [HTTP/2] [1] [:path: /]
    * [HTTP/2] [1] [user-agent: curl/8.12.1]
    * [HTTP/2] [1] [accept: */*]
    > GET / HTTP/2
    > Host: gitlab.optiplex3060:9988
    > User-Agent: curl/8.12.1
    > Accept: */*
    > 
    * Request completely sent off
    * TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
    * TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
    < HTTP/2 302 
    < server: nginx
    < date: Sun, 30 Mar 2025 07:32:56 GMT
    < content-type: text/html; charset=utf-8
    < location: https://gitlab.optiplex3060:9988/users/sign_in
    < cache-control: no-cache
    < content-security-policy: 
    < permissions-policy: interest-cohort=()
    < x-content-type-options: nosniff
    < x-download-options: noopen
    < x-frame-options: SAMEORIGIN
    < x-gitlab-meta: {"correlation_id":"01JQJZFJDRXWJCNCBXEZY9Q8CM","version":"1"}
    < x-permitted-cross-domain-policies: none
    < x-request-id: 01JQJZFJDRXWJCNCBXEZY9Q8CM
    < x-runtime: 0.060143
    < x-ua-compatible: IE=edge
    < x-xss-protection: 1; mode=block
    < strict-transport-security: max-age=63072000
    < referrer-policy: strict-origin-when-cross-origin
    < 
    * Connection #0 to host gitlab.optiplex3060 left intact
    <html><body>You are being <a href="https://gitlab.optiplex3060:9988/users/sign_in">redirected</a>.</body></html>

    ```
    * Nous avons bien une réponse donc notre certificat est valide et permet la communication en ssl/tls:
    
    ```sh
    =>
    * Connection #0 to host gitlab.optiplex3060 left intact
    <html><body>You are being <a href="https://gitlab.optiplex3060:9988/users/sign_in">redirected</a>.</body></html>

    ```