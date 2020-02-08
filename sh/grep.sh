#!/usr/bin/env bash

grep -Rl '#!/' /etc/rc*/* | xargs sed -n 's@#!/@sed-replacemend@p' 
