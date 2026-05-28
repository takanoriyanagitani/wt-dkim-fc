#!/bin/sh

header2dkim(){
  cat /dev/stdin |
    node ./fcdkim.mjs
}

echo none
echo 'Authentication-Results: dummy.example.com
  dkim=none 
' | header2dkim
echo

echo pass
echo 'Authentication-Results: dummy.example.com
  DKIM=none 
  dkim=pass
' | header2dkim
echo

echo fail
echo 'Authentication-Results: dummy.example.com
  DKIM=none 
  dkim=fail
' | header2dkim
echo

echo temperror
echo 'Authentication-Results: dummy.example.com
  DKIM=none 
  dkim=temperror
' | header2dkim
echo
