Zsh
===

Profiling Startup
-----------------

To gain an idea of how fast Zsh takes to startup, run:

```
for i in $(seq 1 10); do /usr/bin/time zsh -i -c exit; done
```

(Replace `zsh` with `bash` for comparison)

Zsh can also be profiled. Put the following line at the top of `zshrc`, run `reload!`, and then run `zprof`.

```
zmodload zsh/zprof
```

Resources:
* https://blog.jonlu.ca/posts/speeding-up-zsh
