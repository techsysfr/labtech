TP 0 : Utilisation des VMs
====================

### Comment utiliser les VMs ?

Chacun vous disposez d'un NODE de 2 VMs.

Pour chaque, vous devez d'abord rebondir en ssh sur l'IP publique. Il y a une entr√©e DNS pour vous faciliter la vie :

```
ssh root@labtech-ansibleXX.lab-techsys.fr
```

Mot de passe : Z********59*

Il sera √crit sur le tableau ;-)

Vous tombez sur la VM **labtech_ansible_master**, o√ vous pourrez installer ansible. De la vous pourrez rebondir sur la **labtech_ansible_slave**.


### Liste des NODES 

Il y en a un pour chacun !


```
NODE 01 -- M.DROUET
DNS = labtech-ansible01.lab-techsys.fr = 213.32.49.83
193 CloudAdmin oneadmin labtech_ansible_master RUNNING CLS01 172.10.0.119 
183 CloudAdmin oneadmin labtech_ansible_slave RUNNING CLS01 172.10.0.109

NODE 02 -- V.LEMIERE
DNS = labtech-ansible02.lab-techsys.fr = 213.32.49.82
192 CloudAdmin oneadmin labtech_ansible_master RUNNING CLS01 172.10.0.118
182 CloudAdmin oneadmin labtech_ansible_slave RUNNING CLS01 172.10.0.108

NODE 03 -- Robin FAGOO
DNS = labtech-ansible03.lab-techsys.fr = 213.32.49.84
191 CloudAdmin oneadmin labtech_ansible_master RUNNING CLS01 172.10.0.117
181 CloudAdmin oneadmin labtech_ansible_slave RUNNING CLS01 172.10.0.107

NODE 04 -- Sebastien WACHTER
DNS = labtech-ansible04.lab-techsys.fr = 213.32.49.85
190 CloudAdmin oneadmin labtech_ansible_master RUNNING CLS01 172.10.0.116
180 CloudAdmin oneadmin labtech_ansible_slave RUNNING CLS01 172.10.0.106

NODE 05 -- Pierre-Marie DENISSELLE
DNS = labtech-ansible05.lab-techsys.fr = 213.32.49.86
189 CloudAdmin oneadmin labtech_ansible_master RUNNING CLS01 172.10.0.115
179 CloudAdmin oneadmin labtech_ansible_slave RUNNING CLS01 172.10.0.105

NODE 06 -- Kevin PRUDHOMME
DNS = labtech-ansible06.lab-techsys.fr = 213.32.49.87
188 CloudAdmin oneadmin labtech_ansible_master RUNNING CLS01 172.10.0.114
178 CloudAdmin oneadmin labtech_ansible_slave RUNNING CLS01 172.10.0.102

NODE 07 -- Emmanuel PENET
DNS = labtech-ansible07.lab-techsys.fr = 213.32.49.88
187 CloudAdmin oneadmin labtech_ansible_master RUNNING CLS01 172.10.0.113
177 CloudAdmin oneadmin labtech_ansible_slave RUNNING CLS01 172.10.0.41

NODE 08 -- Aur√©lien BERTOLASO
DNS = labtech-ansible08.lab-techsys.fr = 213.32.49.89
186 CloudAdmin oneadmin labtech_ansible_master RUNNING CLS01 172.10.0.112
176 CloudAdmin oneadmin labtech_ansible_slave RUNNING CLS01 172.10.0.99

NODE 09 -- Olivier DUQUESNE
DNS = labtech-ansible09.lab-techsys.fr = 213.32.49.91
185 CloudAdmin oneadmin labtech_ansible_master RUNNING CLS01 172.10.0.111
175 CloudAdmin oneadmin labtech_ansible_slave RUNNING CLS01 172.10.0.97

NODE 10 -- Fred CELIE
DNS = labtech-ansible10.lab-techsys.fr = 213.32.49.93
184 CloudAdmin oneadmin labtech_ansible_master RUNNING CLS01 172.10.0.110
174 CloudAdmin oneadmin labtech_ansible_slave RUNNING CLS01 172.10.0.71

NODE 11 -- Emmanuel ROGGE
DNS = labtech-ansible11.lab-techsys.fr = 178.32.157.185
labtech_ansible_master RUNNING GAIDEN-CLS01 192.168.59.108
labtech_ansible_slave RUNNING GAIDEN-CLS01 192.168.59.116

NODE 12 -- Jean-Fran√ßois DUPONT
DNS = labtech-ansible12.lab-techsys.fr = 178.32.157.189
labtech_ansible_master RUNNING GAIDEN-CLS01 192.168.59.148
labtech_ansible_slave RUNNING GAIDEN-CLS01 192.168.59.112

NODE 13 -- Guillaume MAERTE
DNS = labtech-ansible13.lab-techsys.fr = 178.32.157.187
labtech_ansible_master RUNNING GAIDEN-CLS01 192.168.59.110
labtech_ansible_slave RUNNING GAIDEN-CLS01 192.168.59.115

```
