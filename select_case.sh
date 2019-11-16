ciphers=(
aes-256-gcm 
aes-256-cfb
chacha20-ietf-poly1305
xchacha20-ietf-poly1305
)

select cipher in "${ciphers[@]};
do
    case $cipher in aes-256-gcm|aes-256-cfb|chacha20-ietf-poly1305|xchacha20-ietf-poly1305)
      echo "You selected $cipher!"
      cipher=$cipher
      break
      ;;
      *)
      echo "Please select a valid cipher!"
      ;;
    esac
done
