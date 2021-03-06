#!/bin/bash

# Install HomeBrew if it doesn't exist
which -s brew
if [[ $? != 0 ]] ; then
    # Install Homebrew
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    brew update
fi

# Change the Context to Docker's desktop K8S
#kubectl config use-context minikube 
kubectl config use-context docker-for-desktop

# No Longer Needed
# Install minikube
#echo "Installing Minikube CLI..."
#brew cask install minikube

# Install Helm
echo "Installing Helm CLI..."
brew install kubernetes-helm

# No Longer Needed
# Start Minikube
#echo "Starting Minikube..."
#minikube start --memory=4096

# Setup Helm
echo "Setting up Helm..."
helm init
helm repo add riffrepo https://riff-charts.storage.googleapis.com
helm repo update

# Wait for Tiller to start
echo "Waiting for Tiller to start..."
TILLER_WAIT=0
until helm version 1> /dev/null 2> /dev/null
do
  sleep 1
  TILLER_WAIT=$((TILLER_WAIT+1))
  if [ $TILLER_WAIT -eq 30 ]
  then
      echo "Could not connect to Tiller, exiting!"
      exit -1
  fi
done

echo "Tiller ready!"


# Install Riff
echo "Installing Riff..."
helm install riffrepo/riff --name demo --set httpGateway.service.type=NodePort

# Install the Riff CLI
echo "Installing Riff CLI..."
wget https://raw.githubusercontent.com/projectriff/riff/583246872ac95871073f160e5baae895035caa61/riff -O riff
chmod +x riff
mv riff /usr/local/bin/riff

export GATEWAYPORT=`kubectl get svc demo-riff-http-gateway  -o=jsonpath='{.spec.ports[0].nodePort}'`
export GATEWAY="http://localhost:${GATEWAYPORT}"

echo -e "\n\nTo configure your terminal, run...\n
kubectl config use-context docker-for-desktop
export GATEWAY="http://localhost:"\`kubectl get svc demo-riff-http-gateway  -o=jsonpath='{.spec.ports[0].nodePort}'\`
export HEADER=\"Content-Type: text/plain\"
"


