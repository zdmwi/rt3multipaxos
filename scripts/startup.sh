#! /usr/bin/env bash

function install_golang() {
    echo "Installing golang"

    # download golang from the official source
    curl -O https://dl.google.com/go/go1.22.3.linux-amd64.tar.gz
    rm -rf /usr/local/go && tar -C /usr/local -xzf go1.22.3.linux-amd64.tar.gz
}

function clone_repo() {
    echo "Cloning rt3multipaxos repository"

    # cloning rt3multipaxos repository from github
    git clone 
    
}

function main() {
    sudo apt-get -yq update

    install_golang "$@"
}

main "$@"
