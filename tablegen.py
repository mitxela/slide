import math 

avg = {
560:436.569043433616,
561:437.360620822414,
562:438.554533329949,
563:440.563976759006,
564:442.350710059839,
565:443.587376561436,
566:444.382487263602,
567:446.001578996691,
568:447.756594491321,
569:450.99369714606,
570:452.904275527748,
571:454.707364052353,
572:457.58440149089,
573:459.404909886341,
574:462.481467208305,
575:463.239674899938,
576:466.437961954575,
577:468.825824217653,
578:471.998197865144,
579:474.75353161821,
580:477.07044959568,
581:481.255193313456,
582:484.446911161974,
583:488.527643054608,
584:489.974188369389,
585:494.044299482697,
586:496.271110487708,
587:498.927732376133,
588:503.129155839007,
589:504.589982702373,
590:505.981659688267,
591:509.690220866557,
592:513.090552135764,
593:515.795046754375,
594:518.440519007446,
595:521.681116420699,
596:523.225322288544,
597:527.874962375901,
598:529.634753973431,
599:532.497810008508,
600:535.62232701828,
601:538.837085856316,
602:541.908497548892,
603:543.68776284147,
604:545.77762527594,
605:548.469352848056,
606:551.923522878887,
607:555.260323859551,
608:556.507181178967,
609:561.772531205152,
610:564.003686182068,
611:568.519778033241,
612:570.915481816149,
613:572.987385016654,
614:576.365744804696,
615:580.45632999819,
616:581.229206701202,
617:581.954587546182,
618:585.471837034285,
619:588.642651866704,
620:593.241394477888,
621:595.631849158234,
622:599.350909085516,
623:602.804781933975,
624:606.519837816597,
625:608.926204889663,
626:612.964495484589,
627:615.584784029393,
628:617.022626212246,
629:622.633982721711,
630:625.156000435876,
631:628.782073592324,
632:632.473926914219,
633:636.59708920408,
634:638.508863109988,
635:641.737053137926,
636:646.750990702806,
637:650.785717753019,
638:655.034857278802,
639:657.236313290626,
640:663.157337627197,
641:666.821818595464,
642:672.017513427097,
643:673.898178857276,
644:679.132095038442,
645:683.288689376133,
646:688.303562143623,
647:691.207942472429,
648:697.217287864242,
649:701.437260348467,
650:702.29716813146,
651:706.515141086314,
652:708.156685348875,
653:714.766182738847,
654:715.524878495544,
655:721.316987723153,
656:726.861618782981,
657:728.819520609656,
658:736.353436753375,
659:740.524343747542,
660:742.226472449422,
661:742.260395021897,
662:748.10476556698,
663:753.403561232902,
664:757.574833203586,
665:761.774654997634,
666:766.007154428465,
667:771.520413145665,
668:776.60552534957,
669:778.744861575233,
670:782.476047624135,
671:788.35506312423,
672:791.127177595136,
673:796.192151226853,
674:800.261553397862,
675:806.365998331933,
676:812.395825050774,
677:819.015136394135,
678:822.642872799617,
679:823.830730030282,
680:830.825957613492,
681:837.412253439149,
682:840.899409614214,
683:843.860207590039,
684:849.863643034385,
685:854.519366098007,
686:858.693657185926,
687:867.285885300387,
688:872.21106515113,
689:876.823933995441,
690:883.157337800106,
691:890.219369274796,
692:897.771439292401,
693:906.495918666601,
694:906.808607153821,
695:915.40882626497,
696:925.37096632194,
697:930.287479169785,
698:934.557332524077,
699:940.675676894913,
700:941.530258052311,
701:947.71125512897,
702:955.250849786465,
703:959.138748727264,
704:963.058458008366,
705:964.783774700285,
706:971.394267780593,
707:975.082062518592,
708:977.768463290974,
709:981.396483004341,
710:986.381497048717,
711:991.289219649145,
712:998.057057800869,
713:1001.18221502919,
714:1007.93714676028,
715:1014.10539931915,
716:1014.3146214851,
717:1018.58646329198,
718:1023.27690749628,
719:1032.62220972184,
720:1037.29692088434,
721:1044.48363809793,
722:1049.97876877127,
723:1055.94348525662,
724:1061.95909281083,
725:1069.35601296228,
726:1072.82791142326,
727:1076.32229896178,
728:1081.24275208521,
729:1088.55925248358,
730:1094.76188578422,
731:1100.9340103453,
732:1105.18479715247,
733:1110.57293643879,
734:1116.17668482452,
735:1125.16340848155,
736:1130.0860677997,
737:1131.66611571693,
738:1133.92316937523,
739:1140.07701419786,
740:1148.05115719637,
741:1151.39553753259,
742:1157.64533426115,
743:1164.04703120396,
744:1171.25645568334,
745:1176.47590243259,
746:1182.17597292264,
747:1188.57935863094,
748:1189.94725021199,
749:1193.62147770619,
750:1201.88554428889,
751:1206.41070151532,
752:1212.0038917396,
753:1216.69931260596,
754:1223.67680104426,
755:1230.58052387951,
756:1233.84401875585,
757:1239.18872782578,
758:1242.49683998284,
759:1247.93267752452,
760:1250.32902083223,
761:1254.31100814381,
762:1259.3810519225,
763:1266.45166399436,
764:1270.28294000839,
765:1277.72166449179,
766:1282.09272889843,
767:1285.87581374479,
768:1288.12387148436,
769:1296.72132995405,
770:1297.51794116068,
771:1299.02834679967,
772:1304.07178622209,
773:1309.42124408847,
774:1312.33753339797,
775:1314.90539152354,
776:1318.10591713504,
777:1320.94043474256,
778:1324.01895366493,
779:1328.41744268011,
780:1330.30462050148,
781:1333.00029823845,
782:1333.87903968467,
783:1336.5010637301,
784:1338.4959602662
}

table=[]
n = 67.0
while (n<91):
  targetFreq = 440*math.pow(2, (n-69)/12.0 )
  guess=560
  for k in avg:
    error = abs(avg[k]-targetFreq)
    if ( error < abs(avg[guess]-targetFreq) ): guess=k
  table.append(guess)
  n+= 1/32.0

for i in table:
  speed = 0x30 + (0x70-0x30) * ((i-0x230)/(0x310-0x230))**0.666666
  speed = int(speed)
  packed = (i-0x230) & 0xFF
  #if (i-0x230 > 0xFF): speed +=0x80
  print(".db $%02x, $%02x" % (speed, packed))