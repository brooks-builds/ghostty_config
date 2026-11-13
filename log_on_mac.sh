log stream --process $(ps A | rg -v rg | rg ghostty | awk '{print $1}')
