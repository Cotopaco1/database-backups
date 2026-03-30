#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color (Reset)

print_error(){
    echo -e "${RED}ERROR : $1${NC}"
}

print_warning(){
    echo -e "${YELLOW}WARNING : $1${NC}"
}