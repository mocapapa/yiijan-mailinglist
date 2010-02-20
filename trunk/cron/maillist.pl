#!/usr/bin/perl
#
$MLHOME = '/home/users/sakurai/mail-list';
#
# database server が動いているかをチェック
#
$result = system("/home/users/sakurai/mysql/bin/mysql --exec=\"select * from MailingLists\" sakurai_ml -u sakurai -pylugtux923 >/dev/null");
exit if ($result > 0);
#
# mail server が動いているかをチェック
#
#$mail_server='oak.s3.ed.fujitsu.co.jp';
#$result = system("rsh $mail_server date >/dev/null");
#exit if ($result > 0);

chdir("$MLHOME");
#
$result = open (ML, "/home/users/sakurai/mysql/bin/mysql --exec=\"select name, id from MailingLists\" -u sakurai -pylugtux923 sakurai_ml|");
$_ = <ML>;
while (<ML>) {
  chop;
  ($ml, $id) = split(/[ \t]/);
  open (SUB, "/home/users/sakurai/mysql/bin/mysql --exec=\"select email from Subscribers where mlId = '$id'\" -u sakurai -pylugtux923 sakurai_ml|");
  $_ = <SUB>;
  open (REC, "| sort > REC/pugpug-$ml.rec");
  while (<SUB>) {
    print REC $_;
  }	
  close(SUB);
  close(REC);
}
close(ML);

#
# mailing list record をメイルサーバへコピー
#
#system("rm /home/users/sakurai/mail-list/*.rec");
#system("cp *.rec /home/users/sakurai/mail-list");
#
chdir("REC");

open(IN, "ls *.rec|");
while (<IN>) {
    chop;
    $file = $_;
    if (!(-e "../$file")) {
	system("cp $file ../");
    } elsif (system("cmp $file ../$file")) {
	system("cp $file ../");
    }
}
close(IN);

