# Install homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install kubectl
brew install kubectl

# Install Virtualbox
wget http://download.virtualbox.org/virtualbox/5.1.24/VirtualBox-5.1.24-117012-OSX.dmg
# Manual install it!

# Download minukube
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.21.0/minikube-darwin-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/


# Start minikube
minikube start --memory 4096 --cpus 4 --disk-size 40g --kubernetes-version v1.7.0

# Open dashboard
minikube dashboard

# Copy a directory into minikube VM
scp -rp -i ~/.minikube/machines/minikube/id_rsa $(dirname $(pwd))/* docker@$(minikube ip):/home/docker/

# Build dockerfiles
minikube ssh ./dockerfiles/build.sh
