# to create a dummy Xorg process, in case software (like rustdesk) detects Xorg not X
perl -MPOSIX -e '$0=\"Xorg\"; pause' &
exec gnome-session
