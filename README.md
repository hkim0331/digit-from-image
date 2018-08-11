# Help Miyashin's GrandMa! Project

create: 2018-08-05.<br>
update: 2018-08-06, 2018-08-07, 2018-08-11,

* ある時間になったら「血圧測定の時間です」と mysn の声で優しく促す。

* おばあちゃんの血圧計の表示をカメラで読み取る。

* 読み取った値に応じて、「今日も健康でがんばろう」、
「昨日、飲みすぎましたね」とか優しく話しかける。

どんな工夫がいるか？

どんなサブプロジェクトに分けたらいいか？

# FIXME

* 2018-08-09, convert warns.

    ```sh
$ ./find-best-match.rkt ~/Desktop/rgb.png
convert: profile 'icc': 'RGB ': RGB color space not permitted on
grayscale PNG `16x32.png' @
warning/png.c/MagickPNGWarningHandler/1744.
```

    thanks --strip option,
    [ImageMagick](https://github.com/ImageMagick/ImageMagick/issues/884)


# ms-says.rkt: Kyoko さんが話しかける

* time-signal.sh と基本は同じ。細かく制御したいので racket で書き直し。

* racket からのコマンド呼び出しは (system command) で OK。

* 時刻、メッセージをプログラムに埋め込まず、conf ファイルから取る。

    ```sh
$ ms-says -f ms-says.conf
```

  ms-says.conf の内容は、

    ```
"hh:mm:ss" "msg1"
"hh:mm:ss" "msg2"
...
```

# making of ms-says.rkt

最初は対になる -t、-m オプションで時刻とメッセージを与えることを計画した。

```sh
$ ms-says.rkt -t 7:00 -m "good morning" -t 12:00 -m "lunch!"
```

しかし、これでは毎回のデバッグが面倒なので、設計を変更、
```sh
$ ms-says.rkt -f ms-says.conf
```

とし、関数 read-conf で 引数の ms-says.conf を解析、内部リストを作った。
```lisp
(define read-conf
  (lambda (conf)
    (let ((ret '()))
      (call-with-input-file conf
        (lambda (in)
          (let loop ((line (read-line in)))
            (unless (eof-object? line)
              (call-with-input-string line
                (lambda (ln)
                  (let* ((time (read ln))
                         (msg (read ln)))
                   (set! ret (cons (list time msg) ret)))))
              (loop (read-line in))))))
      ret)))
```

が。

# S 式で。

ms-says.conf をS式で書くことにして、

```lisp
(("15:56:00" "おはようございます。")
 ("15:56:05" "ご機嫌はいかがですか？")
 ("15:56:10" "朝ごはんは美味しかったですか？")
 ("15:56:15" "さようなら"))
```

すると read-conf はあっさり、次ですむ。

```lisp
(define read-conf
  (lambda (conf)
    (call-with-input-file conf
      (lambda (in)
        (read in)))))
```

# テンプレートマッチ find-best-match.rkt

* 0 ~ 9 の 7 セグメント数字イメージを用意し、

  ![](templates/0-16x32.png)
  ![](templates/1-16x32.png)
  ![](templates/2-16x32.png)
  ![](templates/3-16x32.png)
  ![](templates/4-16x32.png)
  ![](templates/5-16x32.png)
  ![](templates/6-16x32.png)
  ![](templates/7-16x32.png)
  ![](templates/8-16x32.png)
  ![](templates/9-16x32.png)

* resize は /usr/local/bin/covert を利用、

```sh
$ convert 0.png -resize 16x32! 0-16x32.png
```

* χ2関数はサイズの同じイメージを引数にとり、
  ビット毎引き算し、2乗和をとる

```lisp
(define χ2
  (lambda (src temp)
    (let ((bm1 (make-object bitmap% src))
          (bm2 (make-object bitmap% temp))
          (p1 (bytes 0 0 0 0))
          (p2 (bytes 0 0 0 0))
          (width 16)
          (height 32)
          (ret '()))
      (for ([x (range width)])
        (for ([y (range height)])
          (send bm1 get-argb-pixels x y 1 1 p1)
          (send bm2 get-argb-pixels x y 1 1 p2)
          (set! ret (cons (diff-sq p1 p2) ret))))
      (* 1.0 (/ (apply + (flatten ret)) (* width height))))))
```

# エリア抽出 extract-area.rkt

* 3年PBL 用に作成した
[find-black-spots](https://github.com/hkim0331/find-black-spots)
の成果を利用。

* find-white-frame を作成、

* 白フレームの重心、四隅の座標を算出、

* 相対位置で切り取る。

* 撮影の歪みを補正する（チャレンジ）


# Android 携帯との通信

まあだだよ


---
hiroshi . kimura . 0331 @ gmail . com
