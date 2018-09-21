import math 

avg = {
560:441.65612786397304,
561:442.0303837312847,
562:442.5572952500677,
563:445.11596127631117,
564:446.5294039311451,
565:447.0406503136095,
566:448.95665033356715,
567:452.6022149857806,
568:455.2971461141066,
569:458.68341038598,
570:460.3123857864959,
571:462.6175850694302,
572:463.3484690483526,
573:466.97077707752004,
574:470.42251189249646,
575:471.8617620135186,
576:472.4360053836077,
577:476.5421570903645,
578:478.5059646706998,
579:480.4864608518399,
580:483.5082532947796,
581:485.68312244978677,
582:490.36874563688724,
583:491.8899009769573,
584:494.7726180745457,
585:497.69547222139875,
586:499.1532330797533,
587:502.87411155882114,
588:506.34541162422556,
589:507.0738900490918,
590:509.1174295807683,
591:512.451550747233,
592:516.0261982528552,
593:518.3033000708581,
594:521.3431700297004,
595:523.5987290651376,
596:526.3812274790857,
597:530.2174218509135,
598:531.4178053370221,
599:535.4240408954427,
600:538.5232434574858,
601:541.43194095123,
602:544.5739335570197,
603:546.091613335414,
604:548.1607138096992,
605:552.4972518782189,
606:554.9226784056559,
607:557.6017912446782,
608:561.8386783199694,
609:565.1728332652518,
610:566.7768358832914,
611:571.1215630093966,
612:574.0628531819056,
613:577.1874165895852,
614:579.4932545729863,
615:583.4333850818012,
616:584.7664242599014,
617:586.3717387374029,
618:589.384048210119,
619:592.7584005985718,
620:596.9456710806892,
621:599.9409507579999,
622:602.0376772020325,
623:606.7785858547024,
624:610.6598733362434,
625:612.5433006814171,
626:616.0385643875877,
627:619.4732505056454,
628:621.3244903051768,
629:624.983598514449,
630:629.1227512873683,
631:632.7291394209028,
632:635.7586030926078,
633:639.3299529437154,
634:641.7283134574423,
635:645.3996035247397,
636:649.7739944803695,
637:654.0565040057198,
638:658.0910448484021,
639:660.1760512142054,
640:665.3242493575328,
641:669.8094300500716,
642:674.8111042865823,
643:675.9921976620162,
644:681.405970340785,
645:685.7391218520039,
646:690.3346932343992,
647:693.3836592674543,
648:700.2065862175633,
649:703.8701885940065,
650:705.0780544216049,
651:709.8429404793501,
652:711.899845432921,
653:718.2446606095643,
654:719.5886247087803,
655:724.845681934828,
656:730.5725285275373,
657:733.5475113908806,
658:739.3863230596862,
659:744.5175268397447,
660:747.010892288255,
661:746.8357504364515,
662:752.1618499466815,
663:757.6327815369971,
664:761.0964243849672,
665:766.3792955243906,
666:771.510358901966,
667:774.9959865217348,
668:781.6266397957528,
669:785.0836846894955,
670:788.5200249754881,
671:793.1688348965256,
672:797.0863268847245,
673:802.0264054915763,
674:805.31386317427,
675:810.819946664112,
676:818.3043929520898,
677:824.6399527804042,
678:829.2289877300773,
679:831.7251693293582,
680:837.1330652094525,
681:843.8687182053368,
682:848.3752588379681,
683:851.1688789677123,
684:856.2325670280052,
685:861.2767382079749,
686:867.3644944483035,
687:872.9874856452619,
688:878.1025572822981,
689:879.9888148676202,
690:886.6488861780865,
691:892.5170429766654,
692:896.885271508779,
693:906.3030197507488,
694:908.7228264661517,
695:913.5246003782236,
696:919.400946492598,
697:925.8185128717539,
698:931.2742065819127,
699:937.143045358733,
700:942.2952144851088,
701:947.9057413141331,
702:953.223986934817,
703:959.8560694890928,
704:964.7087491014136,
705:968.0740213750199,
706:974.8586836629245,
707:978.4752048996932,
708:983.6415177947762,
709:989.2888360688942,
710:996.5423884431435,
711:1000.3372688678714,
712:1006.7301925688034,
713:1012.0660677459633,
714:1020.4209982940329,
715:1024.8047273639606,
716:1024.596787548126,
717:1030.4717042703219,
718:1037.209780484472,
719:1043.8045038653981,
720:1048.5326718721765,
721:1054.8929520191218,
722:1061.302186162451,
723:1067.5378117525922,
724:1074.4554186704825,
725:1082.2462574654433,
726:1084.6784113600238,
727:1086.4641617667437,
728:1094.1238794442343,
729:1099.3727378874066,
730:1106.2185077153329,
731:1113.3208425584187,
732:1119.6924847044693,
733:1123.4229665527032,
734:1128.2243145430202,
735:1138.5733094028888,
736:1143.6853037732112,
737:1145.6341913550157,
738:1148.3967392926374,
739:1157.1064942915664,
740:1162.1172144608472,
741:1165.4325587614208,
742:1173.4779899571163,
743:1179.0516796634988,
744:1186.423574530772,
745:1191.2759513018461,
746:1199.2077359945633,
747:1205.4616790347382,
748:1207.4642430079027,
749:1209.0068237410824,
750:1216.6144790801552,
751:1222.649879965269,
752:1227.7622197699711,
753:1232.639235743433,
754:1240.4405696021634,
755:1245.9989924972456,
756:1251.1462738464054,
757:1257.3215990049466,
758:1259.8439818777802,
759:1263.6363744616401,
760:1267.7366586554992,
761:1271.7366233478047,
762:1276.4477687512822,
763:1283.4060747556698,
764:1288.623542477876,
765:1294.4389757167596,
766:1297.5319457468186,
767:1305.2482573253828,
768:1306.4985099026667,
769:1314.7432739794585,
770:1315.1882829662507,
771:1317.7416391765246,
772:1322.981893440328,
773:1327.3381667543279,
774:1331.1566338967868,
775:1333.025603723226,
776:1334.9770898829324,
777:1339.5430604580292,
778:1344.42889974017,
779:1346.60875494507,
780:1347.4000746525226,
781:1350.064025442259,
782:1351.432395222646,
783:1355.1706933111752,
784:1357.2632043631845
}

table=[]
n = 69.0
while (n<89):
  targetFreq = 440*math.pow(2, (n-69)/12.0 )
  guess=560
  for k in avg:
    error = abs(avg[k]-targetFreq)
    if ( error < abs(avg[guess]-targetFreq) ): guess=k
  table.append(guess)
  n+= 1#1/32.0

for i in table:
  speed = 0x30 + (0x70-0x30) * (i-0x230)/(0x310-0x230)
  speed = int(speed)
  packed = (i-0x230) & 0xFF
  #if (i-0x230 > 0xFF): speed +=0x80
  print(".db $%02x, $%02x" % (speed, packed))