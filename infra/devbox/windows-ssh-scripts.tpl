add-content -path c:/users/brcampb/.ssh/config -value @'
Host ${hostname}
  Hostname ${hostname}
  User ${user}
  IdentityFile ${identityfile}
'@