resize:
	for i in ?.png; do \
		convert $$i -resize 16x32! `basename $$i .png`-16x32.png; \
	done

clean:
	${RM} *-16x32.png
