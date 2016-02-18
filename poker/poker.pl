#!/usr/bin/perl
#barf
use warnings;
use strict;

sub again{
#   my $line;
#   print "Do you want to do this again? (y/N):  ";
#   $line = <STDIN>;
#   return (uc $line) eq "Y\n";
   my $line;
   print "Do you want to do this again? (y/N):  ";
   do{
#      print "Do you want to do this again? (y/N):  ";
      $line = <STDIN>;
      my $old = $line;
      $old =~ s/\n//;
      $line =~ s/\n//;
      $line =~ s/\s*//g;
      $line = uc $line;
      unless($line eq "Y" || $line eq "N"){
         print "Unrecognized option \"$old\".  ";
         print "Please re-enter your choice (y/N):  ";
      }
   }until($line eq 'Y' || $line eq 'N');
   return $line eq 'Y';
}

#returns hand, deck, suit, faceValue, fbin, and sbin arrays.
sub loadDeck{
   my $i;
   #my (@hand,@deck,@suit,@faceValue,@fbin,@sbin);
   my ($hand,$deck,$suit,$faceValue,$fbin,$sbin) = @_;
   for($i=0;$i<52;$i++){
      #push(@{$deck},0);
      $deck->[$i] = 0;
   }
   for($i=0;$i<13;$i++){
      push(@${fbin},0);
   }
   for($i=0;$i<4;$i++){
      push(@${sbin},0);
   }
   for($i=0;$i<5;$i++){
      push(@${hand},0);
   }
   $suit->[0] = "Spades";
   $suit->[1] = "Hearts";
   $suit->[2] = "Clubs";
   $suit->[3] = "Diamonds";
   $faceValue->[0] = "Ace";
   $faceValue->[1] = "Deuce";
   $faceValue->[2] = "Three";
   $faceValue->[3] = "Four";
   $faceValue->[4] = "Five";
   $faceValue->[5] = "Six";
   $faceValue->[6] = "Seven";
   $faceValue->[7] = "Eight";
   $faceValue->[8] = "Nine";
   $faceValue->[9] = "Ten";
   $faceValue->[10] = "Jack";
   $faceValue->[11] = "Queen";
   $faceValue->[12] = "King";
   
   #return (\@hand,\@deck,\@suit,\@faceValue,\@fbin,\@sbin);
}

#parameters must be passed by reference
#example &clearBins(\@fbin, \@sbin);
sub clearBins{
   my ($fbin,$sbin) = @_;
   foreach(@$fbin){
      $_ = 0;
   }
   foreach(@$sbin){
      $_ = 0;
   }
}

#parameters must NOT be passed by reference
#example &shuffle(@deck);
sub shuffle{
   foreach(@_){
      $_ = 0;
   }
}

#parameters must NOT be passed by reference
#example call: &placeBet($bet,$coin)
sub placeBet{
   my $bet = $_[0];
   my $coin = $_[1];
   print "How many coins would you like to bet(1 - 50): ";
   do{
      $bet = <STDIN>;
      $bet =~ s/\D*//g;
      $bet =~ s/\n*//g;
#      print "bet: $bet\n";
#      print "coin: $coin\n";
   }until($bet >= 1 && $bet <= 50);
   print "\n\n";
   
   $coin = $coin - $bet;
#   $coin = $coin - 1;
#   $coin = 999;
#   print "after \$$bet bet, coin = $coin\n";
   $_[1] = $coin;
   $_[0] = $bet;
}

#parameters MUST be passed by reference
#example call: &deal(\@hand, \@deck, \@fbin, \@sbin);
sub deal{
   my ($temp,$i);
   my ($hand,$deck,$fbin,$sbin) = @_;
   for($i=0; $i<5; $i++){
      #while($deck[$temp = int(rand(52))]);
      #while(@{$deck}[$temp = int(rand(52))]);
#      $temp = int(rand(52));
#      while(@{$deck}[$temp]){
#         $temp = int(rand(52));
#      }
      do{
         $temp = int(rand(52));
      }while(@{$deck}[$temp]);
      @{$hand}[$i] = $temp;
      @{$deck}[$temp] = 1;
      #my $handU = @{$hand}[$i] % 13;
      #my $handD = @{$hand}[$i] % 4;
      #@{$fbin}[$handU] += 1;
      #@{$sbin}[$handD] += 1;
      #@{fbin}[@{hand}[$i] % 13]++;
      #@{sbin}[@{hand}[$i] % 4]++;
      #@{$fbin}[@{$hand}[$i] % 13] = @{$fbin}[@{$hand}[$i] % 13] + 1;
      @{$fbin}[@{$hand}[$i] % 13]++;
      #@{$sbin}[@{$hand}[$i] % 4] = @{$sbin}[@{$hand}[$i] % 4] + 1;
      @{$sbin}[@{$hand}[$i] % 4]++;
   }
}

#parameters MUST be passed by reference
#example call: &display(\@hand, \@suit, \@faceValue);
sub display{
   my ($hand,$suit,$faceValue) = @_;
   my $i;
   my $disp;
   print "Your cards are: \n";
   for($i =0; $i<5; $i++){
      $disp = $i + 1;
      print "$disp.  ".@{$faceValue}[@{$hand}[$i] % 13]." of ".
            @{$suit}[@{$hand}[$i] %4]."\n";
   }
   print "\n";
}

#parameters must be passed by reference
#example call: &displayWinnings(\@fbin, \@sbin);
sub displayWinnings{
   my ($fbin,$sbin) = @_;
   my $evalHand = evaluateHand($fbin,$sbin);
   if($evalHand == 2000/5){
      print "You have a royal flush!\n";
   }elsif($evalHand == 250/5){
      print "You have a straight flush!\n";
   }elsif($evalHand == 125/5){
      print "You have a four of a kind!\n";
   }elsif($evalHand == 40/5){
      print "You have a full House!\n";
   }elsif($evalHand == 25/5){
      print "You have a flush!\n";
   }elsif($evalHand == 20/5){
      print "You have a straight!\n";
   }elsif($evalHand == 15/5){
      print "You have a three of a kind!\n";
   }elsif($evalHand == 10/5){
      print "You have two pairs!\n";
   }elsif($evalHand == 5/5){
      print "You have one pair!\n";
   }else{
      print "You didn't get a special hand.\n";
   }
}

#parameters must be passed by reference
#example call: &evaulateRoyal(\@fbin, \@sbin);
sub evaluateRoyal{
   my $conditionFlush = 0;
   my $conditionRoyal = 0;
   my $i;
   my ($fbin,$sbin) = @_;
   #print "is evaluateRoyal called?\n";
   for($i = 0; $i < 4; $i++){
      if($fbin->[$i] == 5){
         $conditionFlush = 1;
      }
   }
   if($conditionFlush){
      if($fbin->[0]*$fbin->[9]*$fbin->[10]*$fbin->[11]*$fbin->[12] == 1){
         $conditionRoyal = 1;
      }
   }
   if($conditionFlush && $conditionRoyal){
      return 1;
   }else{
      return 0;
   }
}

#parameters must be passed by reference
#example call: &evaluateStraight(\@fbin);
sub evaluateStraight{
   my $flag = 0;
   my $product;
   my $i;
#   my $fbin = @_;
   my $fbin = $_[0];
   $product = $fbin->[0]*$fbin->[9]*$fbin->[10]*$fbin->[11]*$fbin->[12];
   if($product != 1){
      #for($i=0; $i<13; $i++){
      for($i=0; $i<8; $i++){
         if($fbin->[$i]*$fbin->[$i+1]*$fbin->[$i+2]*$fbin->[$i+3]*
                                                $fbin->[$i+4] == 1){
            $flag = 1;
         }
      }
   }
   if($product == 1){
      $flag = 1;
   }
   if($flag){
      return 1;
   }else{
      return 0;
   }
}
#parameters must be passed by reference
#example call: &evaluateStraightFlush(\@fbin, \@sbin);
sub evaluateStraightFlush{
   my $conditionFlush = 0;
   my $conditionStraight = 0;
   my $i;
   my ($fbin,$sbin) = @_;
#   print "fbin: $fbin\n";
#   print "sbin: $sbin\n";
#   print '$sbin->[0]: '."$sbin->[0]\n";
#   print "does $sbin->[0] == 5?".($sbin->[0] == 5);
   for($i = 0; $i < 4; $i++){
      if($sbin->[$i] == 5){
         $conditionFlush = 1;
      }
   }
   #max [] is [12]
   for($i = 0; $i < 8; $i++){
      if($fbin->[$i]*$fbin->[$i+1]*$fbin->[$i+2]*$fbin->[$i+3]*
                                             $fbin->[$i+4] == 1){
      #if($fbin->[$i]
         $conditionStraight = 1;
      }
   }
   if($conditionFlush && $conditionStraight){
      return 1;
   }else{
      return 0;
   }
}

#parameters must be passed by reference
#example call: &evaluateFullHouse(\@fbin);
sub evaluateFullHouse{
#   my ($threeComponent,$pairComponent) = 0;
   my $threeComponent = 0;
   my $pairComponent = 0;
   my $fbin = $_[0];
#   my $fbin = @_;
   my $i;
   
#   print "do get to full house?\n";
   
   for($i = 0; $i < 13; $i++){
      if($fbin->[$i] == 3){ $threeComponent = 1; }
      if($fbin->[$i] == 2){ $pairComponent = 1; }
   }
   if($threeComponent && $pairComponent){
      return 1;
   }else{
      return 0;
   }
}

#parameters must be passed by reference
#example call: &evaluateTwoPairs(\@fbin);
sub evaluateTwoPairs{
#   my $fbin = @_;
   my $fbin = $_[0];
   my $i;
   my ($firstPair,$secondPair) = 0;
   for($i = 0; $i < 13; $i++){
      if($fbin->[$i] == 2){
         if($firstPair){
            $secondPair = 1;
         }else{
            $firstPair = 1;
         }
      }
   }
   if($firstPair && $secondPair){
      return 1;
   }else{
      return 0;
   }
}

#parameters must be passed by reference
#example call: &evaluateOnePair(\@fbin);
sub evaluateOnePair{
#   my $fbin = @_;
   my $fbin = $_[0];
   my $i;
   my $flag = 0;
   for($i = 0; $i < 13; $i++){
      if($fbin->[$i] == 2 && $i >= 10){
         $flag = 1;
      }
      if($fbin->[$i] == 2 && $i == 0){
         $flag = 1;
      }
   }
   if($flag){
      return 1;
   }else{
      return 0;
   }
}

#parameters must be passed by reference
#example call: &evaluateThreeOfAKind(\@fbin);
sub evaluateThreeOfAKind{
#   my $fbin = @_;
   my $fbin = $_[0];
   my $flag = 0;
   my $i;
   for($i = 0; $i < 13; $i++){
      if($fbin->[$i] == 3){
         $flag = 1;
      }
   }
   if($flag){
      return 1;
   }else{
      return 0;
   }
}

#parameters must be passed by reference
#example call: &evaluateFullHous(\@sbin);
sub evaluateFlush{
#   my $sbin = @_;
   my $sbin = $_[0];
   my $flag = 0;
   my $i;
   for($i = 0; $i < 4; $i++){
      #print "$i: do this do in flush\n";
      if($sbin->[$i] == 5){
         $flag = 1;
      }
   }
   if($flag){
      return 1;
   }else{
      return 0;
   }
}

#parameters must be passed by reference
#example call: &evaluateFourOfAKind(\@fbin);
sub evaluateFourOfAKind{
#   my $fbin = @_;
   my $fbin = $_[0];
   my $flag = 0;
   my $i;
   for($i = 0; $i < 13; $i++){
#      print "$i: do this do in four?\n";
      if($fbin->[$i] == 4){
         $flag = 1;
      }
   }
   if($flag){
      return 1;
   }else{
      return 0;
   }
}

sub debugPrintBins{
   my ($fbin,$sbin) = @_;
   print "Contents of fbin[] array: \n@$fbin\n";
   print "Contents of sbin[] array: \n@$sbin\n";
}

#parameters must be passed by reference
#example call: &evaluateHand(\@fbin,\@sbin);
sub evaluateHand{
   my ($fbin, $sbin) = @_;
#   print "in evaluateHand(): fbin: $fbin\n";
#   print "sbin: $sbin\n";
#   my $temp = &evaluateStraightFlush($fbin,$sbin);
#   print "temp: $temp\n";
   if(&evaluateRoyal($fbin,$sbin)){
      return 2000/5;
   }elsif(&evaluateStraightFlush($fbin,$sbin)){
      return 250/5;
   }elsif(&evaluateFourOfAKind($fbin)){
      return 125/5;
   }elsif(&evaluateFullHouse($fbin)){
      return 40/5;
   }elsif(&evaluateFlush($sbin)){
      return 25/5;
   }elsif(&evaluateStraight($fbin)){
      return 20/5;
   }elsif(&evaluateThreeOfAKind($fbin)){
      return 15/5;
   }elsif(&evaluateTwoPairs($fbin)){
      return 10/5;
   }elsif(&evaluateOnePair($fbin)){
      return 5/5;
   }else{
      return 0/5;
   }
}

#parameters must be passed by reference
#example call: &discard(\@deck,\@hand,\@fbin,\@sbin);
sub discard{
   my ($deck,$hand,$fbin,$sbin) = @_;
   my $position;
   my $flag;
   print "Please enter up to five cards to discard (if any):  ";
   do{
      my $line = <STDIN>;
      my @nums;
      my $size;
      $flag = 1;
      $line =~ s/\D/ /g;
      @nums = split(/ +/,$line);
      $size = scalar @nums;
      foreach(@nums){
         if($_ < 1 || $_ > 5){
            print "$_ is an invalid choice.  Please re-enter your choice.\n";
            $flag = 0;
         }
      }
      if($size > 0 && $flag){
         &dealReplacements($deck,$hand,\@nums,$fbin,$sbin);
      }
   }until($flag);
}

#example call from &discard():
#&dealReplacements($deck,$hand,\@nums,$fbin,$sbin);
sub dealReplacements{
   my ($deck,$hand,$nums,$fbin,$sbin) = @_;
   my $temp;
   my @permute;
   my $i;
#   foreach(@{$nums}){
#      print "\@{\$nums}: $_\n";
#   }
   for($i = 0; $i < 6; $i++){
      push(@permute,1);
   }
   foreach(@{$nums}){
      if($permute[$_]){
         do{
            $temp = int(rand(52));
         }while($deck->[$temp]);
         $permute[$_] = 0;
         #it needs to be -1 because the user enters cards from 1 to 5, not
         #0 to 4 as it would be indexed internally for the array
         $hand->[$_ - 1] = $temp;
         $deck->[$temp] = 1;
         &clearBins($fbin,$sbin);
         for($i = 0; $i < 5; $i++){
            $fbin->[$hand->[$i] % 13] = $fbin->[$hand->[$i] % 13] + 1;
            $sbin->[$hand->[$i] % 4] = $sbin->[$hand->[$i] % 4] + 1;
         }
      }
   }
}

#example call: &giveWinnings($bet,$coin,\@fbin,\@sbin);
sub giveWinnings{
   my ($bet,$coin,$fbin,$sbin) = @_;
   my $i;
   my $evalHand = &evaluateHand($fbin,$sbin);
   
#   print "giveWinnings, here: coin: $coin, bet: $bet\n";
   $coin = $coin + $bet*$evalHand;
   $_[1] = $coin;
}

sub showCoin{
   my $coin = $_[0];
   print "You currently have $coin coins.\n";
}

#main:
my (@hand,@deck,@suit,@faceValue,@fbin,@sbin);
my ($coin,$bet);
&loadDeck(\@hand,\@deck,\@suit,\@faceValue,\@fbin,\@sbin);
print "hand: @hand\n";
print "deck: @deck\n";
print "suit: @suit\n";
print "faceValue: @faceValue\n";
print "fbin: @fbin\n";
print "sbin: @sbin\n";
my $barf = \@fbin;
my $damn = \@sbin;
print "before all: fbin: $barf\n";
print "sbin: $damn\n\n";
system("clear");
$coin = 101;
$bet = 0;
do{
   system("clear");
   &showCoin($coin);
   &placeBet($bet,$coin);
   &deal(\@hand,\@deck,\@fbin,\@sbin);
   &display(\@hand,\@suit,\@faceValue);
   &displayWinnings(\@fbin,\@sbin);
   &showCoin($coin);
   
   &discard(\@deck,\@hand,\@fbin,\@sbin);
   &display(\@hand,\@suit,\@faceValue);
   &displayWinnings(\@fbin,\@sbin);
   
   &giveWinnings($bet,$coin,\@fbin,\@sbin);
   &showCoin($coin);

   &shuffle(@deck);
   &clearBins(\@fbin,\@sbin);
}while(again());
#print "coin-actual: $coin\n";
#my $barf = \@fbin;
#my $damn = \@sbin;
#print "!!fbin: $barf\n";
#print "!!sbin: $damn\n";
#print "hand: @hand\n";
#print "deck: @deck\n";
#print "suit: @suit\n";
#print "faceValue: @faceValue\n";
#print "fbin: @fbin\n";
#print "sbin: @sbin\n";
print "hand: @hand\n";
print "deck: @deck\n";
print "suit: @suit\n";
print "faceValue: @faceValue\n";
print "fbin: @fbin\n";
print "sbin: @sbin\n";
