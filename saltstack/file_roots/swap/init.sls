
create-swap-file:
  cmd.run:
    - name: dd if=/dev/zero of=/.swap count=1000 bs=1M
    - unless: test -f /.swap

init-swap-file:
  cmd.run:
    - name: mkswap /.swap && touch /.swap.mkswap
    - unless: test -f /.swap.mkswap

/.swap:
  mount.swap

