#!/bin/bash

NOCOLOR='\033[0m'
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'

ERROR () {
  echo -e "${RED}ERROR${NOCOLOR}"
  exit
}

DONE () {
  echo -e "${GREEN}DONE${NOCOLOR}"
  sleep 1
}

sudo rm -f /tmp/Salida.txt
case $1 in
	upgrade)
		shift
		sudo rm -rf /tmp/arch-distro
		case $1 in
			-b)
				echo -e "${BLUE}>>Actualizando comandos de CambonOS${NOCOLOR}"
				sleep 2
				cd /tmp
				git clone -b $2 https://github.com/CambonOS/arch-distro
				cd arch-distro
				sudo cp ./cambonos.sh /usr/bin/cambonos || ERROR
				sudo chmod 755 /usr/bin/cambonos || ERROR
				DONE
				;;
			*)
				echo -e "${BLUE}>>Actualizando comandos de CambonOS${NOCOLOR}"
				sleep 2
				cd /tmp
				git clone https://github.com/CambonOS/arch-distro
				cd arch-distro
				sudo cp ./cambonos.sh /usr/bin/cambonos || ERROR
				sudo chmod 755 /usr/bin/cambonos || ERROR
				DONE
				echo -e "${BLUE}\n>>Actualizando paquetes${NOCOLOR}"
				sleep 2
				trizen --noconfirm -Syyu || ERROR
				DONE
				echo -e "${BLUE}\n>>Eliminando paquetes guerfanos${NOCOLOR}"
				sleep 2
				trizen --noconfirm -Rns $(trizen -Qqdt)
				DONE
				echo -e "${BLUE}\n>>Actualizando GRUB${NOCOLOR}"
				sleep 2
				sudo grub-mkconfig -o /boot/grub/grub.cfg || ERROR
				DONE
				;;
		esac
		;;
	clone)
		shift
		rm -rf arch-distro >/tmp/Salida.txt 2>&1
		case $1 in
			-b)
				echo -e "${BLUE}>>Clonando repositorio CambonOS/Arch-Distro${NOCOLOR}"
				sleep 2
				git clone -b $2 https://github.com/CambonOS/arch-distro.git || ERROR
				;;
			*)
				echo -e "${BLUE}>>Clonando repositorio CambonOS/Arch-Distro${NOCOLOR}"
				sleep 2
				git clone https://github.com/CambonOS/arch-distro.git || ERROR
				;;
		esac
		DONE
		;;
	mkiso)
		shift
		if [[ $EUID -ne 0 ]]
		then
			echo -e "${RED}Debese ejecutar como usuario con privilejios${NOCOLOR}"
			exit
		fi
		echo -e "\n${BLUE}>>Carpeta destino ISO:${NOCOLOR}\c"
		read -e -i $(pwd) RUTAD

		echo -e "\n${BLUE}>>Instalando paquetes necesarios${NOCOLOR}"
		sleep 2
		pacman --noconfirm -Sy archiso >/tmp/Salida.txt 2>&1 && DONE || ERROR

		echo -e "\n${BLUE}>>Creando ficheros de configuracion de la ISO${NOCOLOR}"
		sleep 2
		rm -rf /tmp/* >>/tmp/Salida.txt 2>&1
		mkdir /tmp/perfil 
		case $1 in
			-b)
				cd /tmp && git clone -b $2 https://github.com/CambonOS/arch-distro.git >>/tmp/Salida.txt 2>&1 && DONE || ERROR
				;;
			*)
				cd /tmp && git clone https://github.com/CambonOS/arch-distro.git >>/tmp/Salida.txt 2>&1 && DONE || ERROR
				;;
		esac
		cp -r /usr/share/archiso/configs/releng/* /tmp/perfil || ERROR
		cp /tmp/arch-distro/cambonos-install.sh /tmp/perfil/airootfs/usr/local/bin/cambonos-install || ERROR
		echo 'cambonos-install"' >>/tmp/perfil/airootfs/root/.zshrc
		echo -e "camboniso" >/tmp/perfil/airootfs/etc/hostname
		echo -e "KEYMAP=es" >/tmp/perfil/airootfs/etc/vconsole.conf
		cp -r /tmp/arch-distro/iso/* /tmp/perfil || ERROR
		rm /tmp/perfil/syslinux/splash.png
		rm /tmp/perfil/efiboot/loader/entries/archiso-x86_64-speech-linux.conf
		DONE

		echo -e "\n${BLUE}>>Creando la ISO${NOCOLOR}"
		sleep 2
		mkarchiso -v -w /tmp/work -o $RUTAD /tmp/perfil && DONE || ERROR

		echo -e "\n${BLUE}>>Eliminado ficheros/paquetes innecesarios${NOCOLOR}"
		sleep 2
		pacman --noconfirm -Rns archiso >>/tmp/Salida.txt 2>&1
		DONE
		;;
	*)
		echo -e "${RED}Opción ${BLUE}$1${RED} no reconocida.\nLas opciones posibles:\n		${BLUE}cambonos upgrade${NOCOLOR}\n		${BLUE}cambonos mkiso${NOCOLOR}\n		${BLUE}cambonos clone${NOCOLOR}"
		sleep 2
		;;
esac
