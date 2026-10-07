VM="source"
VBoxManage controlvm $VM poweroff
VBoxManage startvm "$VM"
# Altera memoria para 6GB
VBoxManage modifyvm $VM --memory 6144

# Adiciona o controller
VBoxManage storagectl "$VM" \
  --name "IDE Controller" \
  --add ide

# Adiciona o ISO ao controller
VBoxManage storageattach "$VM" \
  --storagectl "IDE Controller" \
  --port 0 \
  --device 0 \
  --type dvddrive \
  --medium "$PWD/aws-failback-livecd-64bit.iso"

#Altra a ordem de boot para iniciar pelo DVD
VBoxManage modifyvm "$VM" \
  --boot1 dvd \
  --boot2 disk \
  --boot3 none \
  --boot4 none

# Após performar o failback, desligue a VM, remova ISO e altere a ordem de boot para iniciar pelo disco
### Remover Iso
VBoxManage storageattach "$VM" \
  --storagectl "IDE Controller" \
  --port 0 \
  --device 0 \
  --type dvddrive \
  --medium none

VBoxManage modifyvm "$VM" \
  --boot1 disk \
  --boot2 dvd

#Permite enviar texto para VM como se estivesse digitando no teclado
# Ideal para enviar as credenciais temporárias da aws sem precisar digitar.
VBoxManage controlvm $VM \
  keyboardputstring ""
