# Bash and GNU bc
a=1.4
b=2.5
#if (( $(bc <<<'$a < $b') )); then
if (( $(echo "$a < $b" | bc -l) )); then
  echo '1.4 is less than 2.5.'
fi
