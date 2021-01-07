# PKILIB_PATH=/var/lib/pki
# if [ -d $PKILIB_PATH ] ; then
#  cd $PKILIB_PATH
#  if [ -d $PKILIB_PATH/.git ] ; then
#   echo "Updating ecrypted virtual drives"
#   git pull
#  fi
#  for p in $PKILIB_PATH/*.evd ; do
#   if [ -f $p ] ; then
#     f=${p%.evd}
#     v=${f##*/}
#     if [-d /mnt/$v.keys ] ; then
#       echo "Opening $p as $v.vd"
#       sudo cryptsetup luksOpen $p $v.vd
#       echo "Mounting $v.vd as /mnt/$v.keys"
#       sudo mount /dev/mapper/$v.vd /mnt/$v
#     else
#       echo "No mount point (/mnt/$v) found
#     fi
#   fi
#  done
# else
#   echo "No pki library found ($PKILIB_PATH)"
# fi
# cd
/usr/bin/vault-mount
