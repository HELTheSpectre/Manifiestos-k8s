# Despliegue de Sitio Web Estático en Kubernetes con Minikube

Este proyecto demuestra cómo desplegar un sitio web estático utilizando Minikube y Kubernetes con el driver de VirtualBox. El contenido del sitio se monta desde una carpeta local a un volumen persistente, usando `hostPath`. 

Tener en cuenta que se trabajo con un entorno de Windows Home. 

# Importante: 

El contenido de la pagina web estatica se encuentra en otro repositorio.

Al utilizar el driver de VirtualBox, se monta el contenido de manera forzada!.

#  Estructura de los repositorios 

- Manifiestos: 

Manifiestos-k8s/
├── deployment.yaml
├── service.yaml
├── pv.yaml
├── pvc.yaml
└── README.md

- WebEstatica: 

WebEstatica/
├── assets/  
│    ├──DSC_0036.JPG
│    ├──banner-bg.jpg
│    ├──banner-texture.png
│    ├──banner-texture@2x.png
│    ├──img-banner@2x.png
│    ├──img-contact-form-bg.jpg
│    ├──img-prop-type@2x.jpg
│    └──logo-header.png
├── index.html
└── style.css

# Requisitos previos

Antes de comenzar, asegurate de tener instalado lo siguiente en tu sistema:

- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Git](https://git-scm.com/)
- [VirtualBox](https://www.oracle.com/es/virtualization/technologies/vm/downloads/virtualbox-downloads.html)

# Pasos para Reproducir el Entorno

1. Clonar los repositorios

    Para clonar los repositorios podes utilizar los siguientes comandos:

    Repositorio manifiestos: "git clonehttps://github.com/HELTheSpectre/Manifiestos-k8s manifiestos-k8s" 

    Repositorio webEstatica: "git clone https://github.com/HELTheSpectre/WebEstatica pagina-web"

    De esta manera, donde este parado en la terminal, se generan las carpetas "manifiestos-k8s" y "pagina-web" con los repositorios clonados.

2. Iniciar Minikube con VirtualBox

    Para iniciar debemos usar: minikube start --driver=virtualbox

3. Compartir el volumen local con Minikube

    Es necesario montar manualmente la carpeta local que contiene el sitio web estático (Esto debe ejecutarse en una terminal separada y mantenerse activo mientras Minikube está corriendo.): 

    minikube mount "C:\...\pagina-web:/mnt/web"

    !Tener en cuenta que se debe colocar la ruta donde esta la carpeta "pagina-web" antes de ":/mnt/web"!.

4. Aplicar los manifiestos de Kubernetes

    kubectl apply -f pv.yaml
    kubectl apply -f pvc.yaml
    kubectl apply -f deployment.yaml
    kubectl apply -f service.yaml

5. Verificar que esté funcionando

    kubectl get all
   

6. Acceder al sitio web

    Podes ingresar al sitio web con: minikube service sitio-web-service


# Notas

- Para borrar los recursos creados: kubectl delete -f .

- Debido a la versión de Windows, se utilizó el driver virtualbox en lugar de hyperv.

- El sitio web se monta usando un PersistentVolume de tipo hostPath, por lo tanto solo funcionará en entornos locales como Minikube.

- El volumen apunta a /mnt/web, que se enlaza desde tu PC mediante minikube mount.

- Asegurate de mantener esa terminal abierta mientras el clúster esté en uso.


# Autor

- Giuliano Moro
- Técnico en Desarrollo de Software
- Argentina

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------