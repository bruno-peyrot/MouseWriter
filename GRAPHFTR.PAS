UNIT GraphFtr;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                                                                           }
{                                GraphFTR                                   }
{                                                                           }
{       - Gestion de fenˆtres en mode graphique pour Turbo Pascal -         }
{                                                                           }
{                      Unit‚ extraite de l'ouvrage:                         }
{                                                                           }
{         ***   BIBLIOTHEQUE DE PROGRAMMES EN TURBO-PASCAL   ***            }
{                                                                           }
{                par Jean-Edouard & Thomas LACHAND-ROBERT                   }
{                                                                           }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

INTERFACE

USES
    Dos,
    Crt,
    TurboLib,
    GraphLib,
    GraphTxt;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
CONST
     coulAlertes   : couleur = rouge;  { couleur de fond des alertes }
     coulDialogues : couleur = bleu;   { couleur de fond des dialogues }
     coulBoutons   : couleur = gris;   { couleur de fond des boutons }
     coulTextes    : couleur = blanc;  { couleur du texte des dialogues }

     tempAlertes : Byte = 0;           { temporisation des alertes }

     normalMsk   = 7;     { saisie normale des choix }
     contourMsk  = 1;     { saisie des choix sans dessin des contours }
     recouvreMsk = 2;     { saisie des choix sans sauvegarde }
     ombreMsk    = 4;     { choix dans une fenˆtre ombr‚e }

     maxFic = 100;        { nb maxi de fichiers dans un r‚pertoire }


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
TYPE
    typDialog = (bord1, bord2, ombre1, ombre2);

    typDlog = RECORD    { d‚finition d'une fenˆtre de dialogue }
                    DTyp     : typDialog;  { type du dialogue }
                    DRect    : rectTxt;    { contour du dialogue }
                    titre    : str80;      { son titre (facultatif) }
                    clTexte  : couleur;    { couleur du titre et du bord }
                    clFond   : couleur;    { couleur du fond }
                    taille   : Word;       { taille des donn‚es recouvertes }
                    donnees  : Pointer;    { donn‚es recouvertes }
              END;

    typChoix = ARRAY [1..100] OF String[40]; { une liste de choix }

    ctrlChoixPtr = ^typCtrlChoix;            { contr“le d'un choix }
    typCtrlChoix =
       RECORD
             action     : (prepare, traite, ferme);  { actions possibles }
             choixCtrl  : Byte;      { modificateur d'ex‚cution }
             cmd        : Char;      { commande recue de l'utilisateur }
             posX       : Byte;      { position horizontale du choix }
             posY       : Byte;      { position verticale du choix }
             nbEcrits   : Integer;   { nb de choix ds la fenˆtre }
             nbMax      : Integer;   { nb de choix maxi }
             result     : Integer;   { choix effectu‚ }
             carCtrl    : Set Of Char;  { caractŠres acceptables }
             don        : Array [1..1000] OF ^str80 ;       { choix }
             contour    : rectTxt;   { rectangle englobant les choix }
             posHaut    : Integer;   { premier choix affich‚ }
             select     : Integer;   { choix s‚lectionn‚ }
             nouvSelect : Integer;   { usage interne }
             taille     : Word;      { taille des donn‚es recouvertes }
             donnees    : Pointer;   { donn‚es recouvertes }
       END;


PROCEDURE centreRect (VAR r : rectTxt;  lInt, hInt : Byte);
PROCEDURE ouvreDialogue (VAR leDlog : typDlog);
PROCEDURE fermeDialogue (VAR leDlog : typDlog);
PROCEDURE alerte (titre : str80);
FUNCTION  dialogueTexte (titre, defaut : str80;  longMax : Byte) : str80;
FUNCTION  dialogueNbr (titre : str80;   min, max, defaut : Integer) : Integer;
FUNCTION  dialogueReel (titre : str80;   min, max, defaut : Real) : Real;
FUNCTION  dialogueBout (titre, bout1, bout2 : str80) : Boolean;
FUNCTION  choix (posX, posY, nbEcrits, nbMax : Byte; VAR result : Byte;
          donnees : typChoix) : Boolean;
FUNCTION  choixFichier (posX, posY : Byte;  VAR repert : nomRep;
          VAR fichier : nomFichier;   titre : str80) : Boolean;


IMPLEMENTATION


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ Calcule dans 'r' un rectangle centr‚ de largeur 'lInt' et hauteur 'hInt'. }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE centreRect (VAR r : rectTxt;  lInt, hInt : Byte);
VAR
   demiLargeur, demiHauteur : Byte;

BEGIN
     IF lInt < 1 THEN
        lInt := 1;
     IF lInt > absX-2 THEN
        lInt := absX-2;
     IF hInt < 1 THEN
        hInt := 1;
     IF hInt > 23 THEN
        hInt := 23;
     demiLargeur := lInt DIV 2;
     demiHauteur := hInt DIV 2;
     WITH r DO
     BEGIN
          x1 := xMil - demiLargeur - 1;
          IF x1 < 1 THEN
             x1 := 1;
          y1 := 12 - demiHauteur;
          IF y1 < 1 THEN
             y1 := 1;
          x2 := x1 + lInt + 1;
          y2 := y1 + hInt + 1;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{            Ouvre la fenˆtre de dialogue d‚finie dans 'leDlog'.              }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE ouvreDialogue (VAR leDlog : typDlog);
VAR
   oldX : Byte;
   rDon : rectTxt;
   s : typSauvGrf;

BEGIN
     WITH leDlog, rDon DO
     BEGIN
          IF DTyp IN [ombre1,ombre2] THEN
             initRect(rDon,DRect.x1,DRect.y1,DRect.x2+1,DRect.y2+1)
          ELSE
             rDon := DRect;
          IF (y2 > y1+1) AND (x2 > x1+1) THEN
          BEGIN
               sauvegarde(s);
               taille := tailleRTxt(rDon);
               GetMem(donnees,taille);
               sauveRectTexte(x1,y1,x2,y2,donnees);
               coulFond(clFond);
               coulTexte(clTexte);
               CASE DTyp OF
                    bord1 : rectTexte(x1,y1,x2,y2,1,True);
                    bord2 : rectTexte(x1,y1,x2,y2,2,True);
                    ombre1,
                    ombre2 :
                    BEGIN
                         coulFond(noir);
                         rectTexte(x1+1,y1+1,x2,y2,0,True);
                         coulFond(clFond);
                         rectTexte(x1,y1,x2-1,y2-1,Ord(DTyp = ombre2)+1,True);
                    END;
               END;
               oldX := xMil;
               xMil := x1 + ((x2 - x1 + 1) DIV 2);
               IF (Length(titre) > 0) AND (Length(titre) < x2 - x1 - 1) THEN
                  centreTexte(y1,' '+titre+' ');
               xMil := oldX;
               restaure(s);
          END;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                   Ferme la fenˆtre de dialogue 'leDlog'.                    }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE fermeDialogue (VAR leDlog : typDlog);
VAR
   rDon : rectTxt;

BEGIN
     WITH leDlog DO
          IF (taille > 0) AND (donnees <> NIL) THEN
          BEGIN
               IF DTyp IN [ombre1,ombre2] THEN
                  initRect(rDon,DRect.x1,DRect.y1,DRect.x2+1,DRect.y2+1)
               ELSE
                  rDon := DRect;
               WITH rDon DO
                    litRectTexte(x1,y1,x2,y2,donnees);
               FreeMem(donnees,Taille);
               donnees := NIL;
          END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ Message d'alerte. Si 'tempAlertes' vaut 0, une touche de validation est     }
{ attendue, sinon, sa valeur d‚fini la dur‚e de l'alerte.                     }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE alerte (titre : str80);
VAR
   dlg : typDlog;
   s : typSauvGrf;

BEGIN
     IF titre <> '' THEN
     BEGIN
          sauvegarde(s);
          centreRect(dlg.DRect,Length(titre)+2,3);
          WITH dlg DO
          BEGIN
               titre := '';
               DTyp := ombre2;
               clFond := coulAlertes;
               clTexte := coulTextes;
          END;
          ouvreDialogue(dlg);
          coulFond(coulAlertes);
          coulTexte(coulTextes);
          centreTexte(13,titre);
          IF faitBip THEN
          BEGIN
               Sound(600);
               Delay(50);
               Sound(400);
               Delay(50);
               NoSound;
          END;
          IF tempAlertes <> 0 THEN
             Delay(tempAlertes * Length(titre))
          ELSE
             attendAction;
          fermeDialogue(dlg);
          restaure(s);
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{  Saisie d'une donn‚e alphanum‚rique de longueur 'longMax' dans un dialogue. }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION dialogueTexte (titre, defaut : str80;  longMax : Byte) : str80;
VAR
   dlg : typDlog;
   cmd : Char;
   s : typSauvGrf;

BEGIN
     IF (Length(titre) < 76) AND (Length(defaut) <= longMax)
        AND (longMax< 76) THEN
     BEGIN
          sauvegarde(s);
          IF Length(titre) > longMax THEN
             centreRect(dlg.DRect,Length(titre)+2,3)
          ELSE
             centreRect(dlg.DRect,LongMax+2,3);
          WITH dlg DO
          BEGIN
               titre := '';
               DTyp := ombre2;
               clFond := coulDialogues;
               clTexte := coulTextes;
          END;
          ouvreDialogue(dlg);
          coulFond(coulDialogues);
          coulTexte(coulTextes);
          centreTexte(12,titre);
          dialogueTexte := litDonnee(xMil - longMax DIV 2,14,longMax,1,defaut);
          fermeDialogue(dlg);
          restaure(s);
     END
     ELSE
         dialogueTexte := defaut;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{          Saisie d'une donn‚e entiŠre comprise entre 'min' et 'max'.         }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION dialogueNbr (titre : str80;   min, max, defaut : Integer) : Integer;
VAR
   strg, maxStr, defautStr : numAlpha;
   strVal, long : Integer;
   cmd : Char;
   dlg : typDlog;
   s : typSauvGrf;

BEGIN
     IF (Length(titre) < 76) AND (min < max) AND (defaut >= min)
        AND (defaut <= max) THEN
     BEGIN
          sauvegarde(s);
          maxStr := intToStr(max);
          long := Length(maxStr);
          IF Length(titre) > long THEN
             centreRect(dlg.DRect,Length(titre)+2,3)
          ELSE
             centreRect(dlg.DRect,Long+2,3);
          WITH dlg DO
          BEGIN
               titre := '';
               DTyp := ombre2;
               clFond := coulDialogues;
               clTexte := coulTextes;
          END;
          ouvreDialogue(dlg);
          coulFond(coulDialogues);
          coulTexte(coulTextes);
          centreTexte(12,titre);
          defautStr := intToStr(defaut);
          REPEAT
                strg := litDonnee(xMil - long DIV 2,14,long,2,defautStr);
                strVal := strToInt(strg);
                IF (strVal < min) OR (strVal > max) THEN
                   strg := '';
          UNTIL strg <> '';
          dialogueNbr := strVal;
          fermeDialogue(dlg);
          restaure(s);
     END
     ELSE
         dialogueNbr := defaut;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{           Saisie d'une donn‚e r‚elle comprise entre 'min' et 'max'.         }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION dialogueReel (titre : str80;   min, max, defaut : Real) : Real;
VAR
   strg, defautStr : numAlpha;
   strVal : Real;
   cmd : Char;
   dlg : typDlog;
   s : typSauvGrf;

BEGIN
     IF (Length(titre) < 76) AND (min < max) AND (defaut >= min)
        AND (defaut <= max) THEN
     BEGIN
          sauvegarde(s);
          IF Length(titre) > 12 THEN
             centreRect(dlg.DRect,Length(titre)+2,3)
          ELSE
             centreRect(dlg.DRect,14,3);
          WITH dlg DO
          BEGIN
               titre := '';
               DTyp := ombre2;
               clFond := coulDialogues;
               clTexte := coulTextes;
          END;
          ouvreDialogue(dlg);
          coulFond(coulDialogues);
          coulTexte(coulTextes);
          centreTexte(12,titre);
          defautStr := realToStr(defaut,12,2);
          REPEAT
                strg := litDonnee(xMil - 6,14,12,typeReel,defautStr);
                strVal := strToReal(strg);
                IF (strVal < min) OR (strVal > max) THEN
                   strg := '';
          UNTIL strg <> '';
          dialogueReel := strVal;
          fermeDialogue(dlg);
          restaure(s);
     END
     ELSE
         dialogueReel := defaut;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{  Dessine un dialogue comportants deux boutons 'bout1' et 'bout2' de choix.  }
{   (le choix 1 est retourn‚ par d‚faut par l'appui de la touche d'entr‚e.)   }
{  Une valeur bool‚enne vraie en retour indique le choix du bouton 1.         }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION dialogueBout (titre, bout1, bout2 : str80) : Boolean;
VAR
   long, longBis : Integer;
   r1, r2 : rectTxt;
   gr1, gr2 : rect;
   bouton1 : Boolean;
   dlg : typDlog;
   car : Char;
   env : typSauvGrf;

BEGIN
     sauvegarde(env);
     WHILE Length(bout1) < Length(bout2) DO
           bout1 := Concat(' ',bout1,' ');
     IF Length(bout1) > 34 THEN
        bout1 := Copy(bout1,1,34);
     IF Length(bout2) > 34 THEN
        bout2 := Copy(bout2,1,34);
     long := Length(bout1)+2;
     WHILE (long * 2) + 4 > Length(titre) DO
           titre := Concat(' ',titre,' ');
     centreRect(dlg.DRect,Length(titre)+2,5);
     WITH dlg DO
     BEGIN
          titre := '';
          DTyp := ombre2;
          clFond := coulDialogues;
          clTexte := coulTextes;
     END;
     ouvreDialogue(dlg);
     coulFond(coulDialogues);
     coulTexte(coulTextes);
     centreTexte(11,titre);
     longBis := long + (long DIV 2);
     IF longBis > Length(titre) DIV 2 THEN
        longBis := Length(titre) DIV 2;
     coulFond(coulBoutons);
     WITH r1 DO
     BEGIN
          x1 := xMil-longBis;
          y1 := 13;
          x2 := x1 + long + 1;
          y2 := 15;
          rectTexte(x1,y1,x2,y2,2,TRUE);
     END;
     rTxtToRect(r1,gr1);
     WITH r2 DO
     BEGIN
          x1 := xMil-1+longBis-long;
          y1 := 13;
          x2 := x1 + long + 1;
          y2 := 15;
          rectTexte(x1,y1,x2,y2,1,TRUE);
     END;
     rTxtToRect(r2,gr2);
     GotoXY(xMil+2-longBis,14);
     Write(graf,bout1);
     GotoXY(xMil+longBis- (long+ Length(bout2)) DIV 2,14);
     Write(graf,bout2);
     bouton1 := TRUE;
     car := carNul;
     REPEAT
           execSouris;
           IF boutSouris = 1 THEN
           BEGIN
                IF PtDsRect(posSouris,gr1) THEN
                     car := carRet
                ELSE
                    IF PtDsRect(posSouris,gr2) THEN
                    BEGIN
                         car := carRet;
                         bouton1 := False;
                    END;
           END;
           IF KeyPressed THEN
              car := ReadKey;
     UNTIL car = carRet;
     dialogueBout := bouton1;
     coulFond(coulTextes);
     coulTexte(coulBoutons);
     IF bouton1 THEN
     BEGIN
          GotoXY(xMil+2-longBis,14);
          Write(graf,bout1);
     END
     ELSE
     BEGIN
          GotoXY(xMil+longBis- (long+ Length(bout2)) DIV 2,14);
          Write(graf,bout2);
     END;
     Delay(100);
     fermeDialogue(dlg);
     restaure(env);
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{    Scrolle la zone rectangulaire d‚finie par les deux points textes       }
{                  'h,g' et 'b,d' de 'nbLn' de textes.                      }
{                 (ne fonctionne qu'en blanc sur noir)                      }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE scrollRectTexte (x1, y1, x2, y2 : Byte;   nbLn : ShortInt);
VAR
   offset2, offset, row, il, deb, fin, i, taille : Word;
   donPtr : Pointer;

BEGIN
     cacheSouris;
     taille := (x2-x1+1)*8 * (y2-y1+1)*grHLigne;
     GetMem(donPtr,taille);
     row := x2-x1+1;
     offset := x1-1;
     deb := (y1-1)*grHligne;
     fin := (y2*grHligne)-1;
     offset2 := 0;
     FOR il := deb TO fin DO
     BEGIN
          System.Move(Mem[baseEcran:grOfsY[il]+offset],
                      Mem[Seg(donPtr^):Ofs(donPtr^)+offset2],row);
          offset2 := offset2 + row;
     END;
     IF nbLn < 0 THEN
     BEGIN
          nbLn := Abs(nbLn);
          offset2 := row*(nbLn*grHLigne);
          FOR il := deb TO fin-grHLigne DO
          BEGIN
               System.Move(Mem[Seg(donPtr^):Ofs(donPtr^)+offset2],
                           Mem[baseEcran:grOfsY[il]+offset],row);
               offset2 := offset2 + row;
          END;
     END
     ELSE
     BEGIN
          offset2 := offset2 - row - row*(nbLn*grHligne);
          FOR il := fin DOWNTO deb+grHLigne DO
          BEGIN
               System.Move(Mem[Seg(donPtr^):Ofs(donPtr^)+offset2],
                           Mem[baseEcran:grOfsY[il]+offset],row);
               offset2 := offset2 - row;
          END;
     END;
     FreeMem(donPtr,taille);
     montreSouris;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{                Choix contr“l‚ d'un texte dans une liste.                  }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
PROCEDURE actChoix (ctrlChoix : ctrlChoixPtr);
VAR
   larg, il : Byte;
   ok, change, tropDeFic : Boolean;
   car : Char;
   rT : rectTxt;
   rG, rSouris : Rect;
   posT : posTxt;

PROCEDURE scrollUp;
VAR
   rLoc : Rect;

BEGIN
     rLoc := rG;
     WITH ctrlChoix^ DO
          IF posHaut <= nbMax - nbEcrits THEN
          BEGIN
               rLoc.y1 := rLoc.y2 - grHLigne;
               IF select <> 0 THEN
                  inverseTexte(contour.x1+1,select+contour.y1,larg);
               posHaut := posHaut+1;
               scrollRectTexte(rt.x1,rt.y1,rt.x2,rt.y2,-1);
               EffaceRect(rLoc);
               il := nbEcrits - 1;
               GotoXY(contour.x1+2,nbEcrits+contour.y1);
               Write(graf,don[posHaut+il]^);
               IF (boutSouris = 1) AND (select > 1) THEN
                  select := select - 1;
               IF select <> 0 THEN
                  inverseTexte(contour.x1+1,select+contour.y1,larg);
               nouvSelect := 0;
          END
          ELSE
              unBip;
END;

PROCEDURE scrollDown;
VAR
   rLoc : Rect;

BEGIN
     rLoc := rG;
     WITH ctrlChoix^ DO
          IF posHaut > 1 THEN
          BEGIN
               rLoc.y2 := rLoc.y1 + grHLigne;
               IF select <> 0 THEN
                  inverseTexte(contour.x1+1,select+contour.y1,larg);
               posHaut := posHaut-1;
               scrollRectTexte(rt.x1,rt.y1,rt.x2,rt.y2,1);
               EffaceRect(rLoc);
               GotoXY(contour.x1+2,1+contour.y1);
               Write(graf,don[posHaut]^);
               IF (boutSouris = 1) AND (select < nbEcrits) THEN
                  select := select + 1;
               IF select <> 0 THEN
                  inverseTexte(contour.x1+1,select+contour.y1,larg);
               nouvSelect := 0;
          END
          ELSE
              unBip;
END;

PROCEDURE vaPgBas;
BEGIN
     IF ctrlChoix^.posHaut + ctrlChoix^.nbEcrits <= ctrlChoix^.nbMax THEN
     BEGIN
          ctrlChoix^.posHaut := ctrlChoix^.posHaut+ctrlChoix^.nbEcrits;
          change := TRUE;
          ctrlChoix^.nouvSelect := ctrlChoix^.select;
          IF ctrlChoix^.nouvSelect + ctrlChoix^.posHaut > ctrlChoix^.nbMax THEN
             ctrlChoix^.nouvSelect := ctrlChoix^.nbMax - ctrlChoix^.posHaut+1;
     END
     ELSE
         ctrlChoix^.nouvSelect := ctrlChoix^.nbMax-ctrlChoix^.posHaut+1;
END;

PROCEDURE vaPgHaut;
BEGIN
     IF ctrlChoix^.posHaut - ctrlChoix^.nbEcrits >= 1 THEN
     BEGIN
          ctrlChoix^.posHaut := ctrlChoix^.posHaut-ctrlChoix^.nbEcrits;
          change := TRUE;
          ctrlChoix^.nouvSelect := ctrlChoix^.select;
     END
     ELSE
       IF ctrlChoix^.posHaut > 1 THEN
       BEGIN
           IF ctrlChoix^.select + ctrlChoix^.posHaut > ctrlChoix^.nbEcrits THEN
               ctrlChoix^.nouvSelect := ctrlChoix^.posHaut + ctrlChoix^.select
                 - ctrlChoix^.nbEcrits
           ELSE
               ctrlChoix^.nouvSelect := 1;
           ctrlChoix^.posHaut := 1;
           change := TRUE;
       END
       ELSE
           ctrlChoix^.nouvSelect := 1;
END;

PROCEDURE eventScroll;
BEGIN
     WITH ctrlChoix^ DO
          IF posT.y = contour.y2-1 THEN
             scrollUp
          ELSE
              IF posT.y = contour.y1+1 THEN
                 scrollDown
              ELSE
                  IF posT.y = contour.y2 -2 THEN
                     vaPgBas
                  ELSE
                      IF posT.y = contour.y1+2 THEN
                         vaPgHaut
                      ELSE
                          unBip;
END;

PROCEDURE update;
BEGIN
     IF ctrlChoix^.nouvSelect <> 0 THEN
     BEGIN
          IF (ctrlChoix^.select <> 0)
             AND (ctrlChoix^.nouvSelect <> ctrlChoix^.select) THEN
             inverseTexte(ctrlChoix^.contour.x1+1,
             ctrlChoix^.select+ctrlChoix^.contour.y1,larg);
          IF ctrlChoix^.select <> ctrlChoix^.nouvSelect THEN
             inverseTexte(ctrlChoix^.contour.x1+1,
             ctrlChoix^.nouvSelect+ctrlChoix^.contour.y1,larg);
             ctrlChoix^.select := ctrlChoix^.nouvSelect;
     END
     ELSE
         ctrlChoix^.nouvSelect := ctrlChoix^.select;
END;

BEGIN
     WITH ctrlChoix^ DO
     BEGIN
        tropDeFic := nbMax > nbEcrits;
        CASE action OF

           prepare :
           BEGIN
                coulTexte(blanc);
                coulFond(noir);
                don[1]^ := don[1]^;
                larg := 0;
                FOR il := 1 TO nbMax DO
                    IF Length(don[il]^) > larg THEN
                       larg := Length(don[il]^);
                larg := larg + 2;
                IF Odd(larg) THEN
                   larg := larg + 1;
                IF posY + nbEcrits + 1 <= absY THEN
                   contour.y1 := posY
                ELSE
                   contour.y1 := absY - nbEcrits - 1;
                contour.y2 := contour.y1 + nbEcrits + 1;
                IF posX + larg + 1 <= absX THEN
                   contour.x1 := posX
                ELSE
                   contour.x1 := absX - larg - 1;
                IF tropDeFic THEN
                   contour.x2 := contour.x1 + larg + 3
                ELSE
                    contour.x2 := contour.x1 + larg + 1;
                IF choixCtrl AND recouvreMsk <> 0 THEN
                   WITH contour DO
                   BEGIN
                        taille := tailleRTxt(contour);
                        GetMem(donnees,taille);
                        sauveRectTexte(x1,y1,x2,y2,donnees);
                   END;
                IF choixCtrl AND contourMsk <> 0 THEN
                   rectTexte(contour.x1,contour.y1,contour.x2,contour.y2,2,
                      TRUE);
                IF (result > nbMax) OR (result < 1) THEN
                   result := 1;
                IF tropDeFic AND (result > nbEcrits) THEN
                BEGIN
                     posHaut := (result DIV nbEcrits) * nbEcrits;
                     select := (result MOD nbEcrits) + 1;
                     nouvSelect := select;
                END
                ELSE
                BEGIN
                     posHaut := 1;
                     select := result;
                     nouvSelect := result;
                END;
           END;

           traite :
           BEGIN
              IF tropDeFic THEN
              BEGIN
                   rT := contour;
                   rT.x1 := rT.x2-2;
                   rectTexte(rt.x1,rt.y1,rt.x2,rt.y2,2,True);
                   GotoXY(rt.x1,rt.y1);
                   Write(graf,#203);
                   GotoXY(rt.x1,rt.y2);
                   Write(graf,#202);
                   rTxtToRect(rt,rSouris);
                   coulTexte(jaune);
                   GotoXY(contour.x2-1,contour.y1+1);
                   Write(graf,#30);
                   GotoXY(contour.x2-1,contour.y2-1);
                   Write(graf,#31);
                   coulTexte(orange);
                   GotoXY(contour.x2-1,contour.y1+2);
                   Write(graf,#30);
                   GotoXY(contour.x2-1,contour.y2-2);
                   Write(graf,#31);
                   coulTexte(blanc);
                   contour.x2 := contour.x2 - 2;
              END;
              WITH contour DO
                   initRect(rT,x1+1,y1+1,x2-1,y2-1);
              rTxtToRect(rT,rG);
              larg := contour.x2 - contour.x1 - 1;
              ok := FALSE;
              dessFond := False;
              REPEAT
                  EffaceRect(rG);
                  FOR il := 1 TO nbEcrits DO
                  BEGIN
                       IF posHaut-1+il <= nbMax THEN
                       BEGIN
                            GotoXY(contour.x1+2,il+contour.y1);
                            Write(graf,don[posHaut-1+il]^);
                       END;
                       IF choixCtrl AND contourMsk <> 0 THEN
                       BEGIN
                            dessFond := True;
                            Gotoxy(contour.x1+(larg DIV 2),contour.y1);
                            IF posHaut > 1 THEN
                               Write(graf,#30,#30)
                            ELSE
                               Write(graf,#205,#205);
                            Gotoxy(contour.x1+(larg DIV 2),contour.y1+
                               nbEcrits+1);
                            IF posHaut+nbEcrits <= nbMax THEN
                               Write(graf,#31,#31)
                            ELSE
                               Write(graf,#205,#205);
                            dessFond := False;
                       END;
                  END;
                  IF select <> 0 THEN
                     inverseTexte(contour.x1+1,select+contour.y1,larg);
                  change := FALSE;
                  REPEAT
                      execSouris;
                      IF boutSouris = 1 THEN
                      BEGIN
                         ptToPTxt(posSouris,posT);
                         IF tropDeFic AND ptDsRect(posSouris,rSouris) THEN
                         BEGIN
                              eventScroll;
                              update;
                         END
                         ELSE
                         BEGIN
                            IF posT.x IN [contour.x1..contour.x2] THEN
                              IF (posT.y > contour.y1)
                                 AND (posT.y < contour.y2) THEN
                              BEGIN
                                   nouvSelect := posT.y - contour.y1;
                                       IF nouvSelect + posHaut - 1 > nbMax THEN
                                          nouvSelect := 0;
                              END;
                            update;
                         END;
                      END
                      ELSE
                          IF boutSouris = 2 THEN
                          BEGIN
                               ptToPTxt(posSouris,posT);
                               IF posT.x IN [contour.x1..contour.x2] THEN
                                  IF (posT.y > contour.y1) AND
                                     (posT.y < contour.y2) THEN
                                  BEGIN
                                       il := posT.y - contour.y1;
                                       ok := il = select;
                                       car := carRet;
                                  END;
                          END;
                      IF KeyPressed THEN
                      BEGIN
                           car := ReadKey;
                           IF (car = carNul) AND KeyPressed THEN
                           BEGIN
                                car := ReadKey;
                                ok := car IN carCtrl;
                                CASE car OF
                                     flchHaut :
                                     IF tropDeFic AND (select = 1) THEN
                                        scrollDown
                                     ELSE
                                         IF (nouvSelect-1+posHaut > 1) THEN
                                            nouvSelect := select - 1;
                                     flchBas :
                                     IF tropDeFic AND (select = nbEcrits) THEN
                                        scrollUp
                                     ELSE
                                         IF (nouvSelect-1+posHaut < nbMax) THEN
                                            nouvSelect := select + 1;
                                     flchPgBas  : vaPgBas;
                                     flchPgHaut : vaPgHaut;
                                END;
                                update;
                           END
                           ELSE
                               ok := car IN carCtrl;
                      END;
                  UNTIL change OR ok;
              UNTIL ok;
              dessFond := True;
              cmd := car;
              result := select+posHaut-1;
           END;

           ferme :
           BEGIN
                IF choixCtrl AND recouvreMsk <> 0 THEN
                   WITH contour DO
                   BEGIN
                        IF tropDeFic THEN
                           contour.x2 := contour.x2 + 2;
                        litRectTexte(x1,y1,x2,y2,donnees);
                        FreeMem(donnees,taille);
                   END;
           END;
        END;
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{           Choix d'un texte dans une liste de type 'typChoix'.             }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION choix (posX, posY, nbEcrits, nbMax : Byte; VAR result : Byte;
               donnees : typChoix) : Boolean;
VAR
   ctrlC : ctrlChoixPtr;
   il : Byte;

BEGIN
     IF (nbEcrits < absY-2) AND (nbMax <= 100) THEN
     BEGIN
          New(ctrlC);
          ctrlC^.posX := posX;
          ctrlC^.posY := posY;
          ctrlC^.nbEcrits := nbEcrits;
          ctrlC^.nbMax := 0;
          ctrlC^.result := result;
          ctrlC^.carCtrl := [carRet,carEsc];
          REPEAT
                ctrlC^.nbMax := ctrlC^.nbMax + 1;
                IF donnees[ctrlC^.nbMax] <> '' THEN
                BEGIN
                     New(ctrlC^.don[ctrlC^.nbMax]);
                     ctrlC^.don[ctrlC^.nbMax]^ := donnees[ctrlC^.nbMax];
                END;
          UNTIL (donnees[ctrlC^.nbMax] = '') OR (ctrlC^.nbMax = nbMax);
          IF ctrlC^.nbMax < nbMax THEN
             ctrlC^.nbMax := ctrlC^.nbMax - 1;
          ctrlC^.choixCtrl := normalMsk;
          ctrlC^.action := prepare;
          actChoix(ctrlC);
          ctrlC^.action := traite;
          REPEAT
                actChoix(ctrlC);
          UNTIL (ctrlC^.cmd IN [carEsc,carRet]);
          FOR il := 1 TO ctrlC^.nbMax DO
              Dispose(ctrlC^.don[il]);
          IF ctrlC^.cmd = carRet THEN
          BEGIN
               result := ctrlC^.result;
               choix := True;
          END
          ELSE
              choix := False;
          ctrlC^.action := ferme;
          actChoix(ctrlC);
          Dispose(ctrlC);
     END;
END;


{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{     Choix d'un fichier du r‚pertoire 'repert' et de masque 'fichier'.     }
{   Titre est le titre de la fenˆtre de choix affich‚e en 'posX','posY'.    }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
FUNCTION choixFichier (posX, posY : Byte;  VAR repert : nomRep;
                      VAR fichier : nomFichier;   titre : str80) : Boolean;
VAR
   nbFic, largeur, il : Integer;
   long, haut, bas, droite, gauche, select, xChoix, yChoix : Byte;
   afficheRep, fin : Boolean;
   data : typChoix;
   lastRep, temp : nomFichier;
   dlg : TypDlog;
   s : typSauvGrf;


FUNCTION litDir : Boolean;
VAR
   leRepert : repRecPtr;
   nbRep, il, jl : Byte;
   temp : String[20];

BEGIN
     IF repert[Length(repert)] = '\' THEN
        Delete(repert,Length(repert),1);
     nbFic := 1;
     select := 1;
     il := Length(repert);
     WHILE NOT (repert[il] IN ['\',':']) DO
           il := il - 1;
     IF repert[il] = ':' THEN
        data[1] := ' ' + repert
     ELSE
        data[1] := #17 + ' '+ Copy(repert,il,Length(repert)-il+1);
     data[1] := elargiADte(data[1],16);
     New(leRepert);
     WITH leRepert^ DO
     BEGIN
          attribut := Directory+ReadOnly;
          repertoire := repert;
          masque := '*.*';
     END;
     listeRep(leRepert);
     WITH leRepert^ DO
     IF (erreurES <> 1) AND (nbDossiers > 0) THEN
     BEGIN
          FOR il := 1 TO nbDossiers DO
          BEGIN
               select := select + 1;
               nbFic := nbFic + 1;
               data[nbFic] := #16 + ' ' + dossiers[il];
          END;
          IF nbDossiers > 1 THEN
             FOR il := 2 TO nbDossiers DO
                 FOR jl := il+1 TO nbDossiers + 1 DO
                     IF data[jl] < data[il] THEN
                     BEGIN
                          temp := data[il];
                          data[il] := data[jl];
                          data[jl] := temp;
                     END;
     END;
     nbRep := leRepert^.nbDossiers;
     IF fichier <> '*.' THEN
     BEGIN
          WITH leRepert^ DO
          BEGIN
               attribut := Archive;
               repertoire := repert;
               masque := fichier;
          END;
          listeRep(leRepert);
          WITH leRepert^ DO
          IF erreurES <> 1 THEN
          BEGIN
               nbDossiers := nbRep;
               IF nbFichiers > 0 THEN
               BEGIN
                    FOR il := 1 TO nbFichiers DO
                        IF nbFic < maxFic THEN
                        BEGIN
                             nbFic := nbFic + 1;
                             data[nbFic] := '  ' + fichiers[il];
                        END;
                    IF nbFichiers > 1 THEN
                       FOR il := nbFic DOWNTO nbDossiers + 3 DO
                            FOR jl := il-1 DOWNTO nbDossiers + 2 DO
                                IF data[jl] > data[il] THEN
                                BEGIN
                                     temp := data[il];
                                     data[il] := data[jl];
                                     data[jl] := temp;
                                END;
                    select := select + 1;
               END
               ELSE
               BEGIN
                    IF (nbDossiers > 0) AND (lastRep <> '') THEN
                    BEGIN
                         il := 1;
                         REPEAT
                               il := il + 1;
                         UNTIL (data[il] = lastRep) OR (il = nbDossiers + 1);
                         IF data[il] = lastRep THEN
                            select := il;
                    END;
               END;
          END
          ELSE
              litDir := False;
     END
     ELSE
     BEGIN
          FOR il := nbFic DOWNTO 1 DO
              data[il+1] := data[il];
          nbFic := Succ(nbFic);
          select := Succ(select);
          temp := '< Valider >';
          data[1] := temp;
     END;
     Dispose(leRepert);
END;

FUNCTION testeDrive (drive : Char) : Boolean;
VAR
   s : SearchRec;
   p : Pointer;
   reg : Registers;

BEGIN
     IF NOT (drive IN ['A','B']) THEN
     BEGIN
          FindFirst(drive+':*.*',AnyFile,s);
          testeDrive := DosError = 0;
     END
     ELSE
     WITH reg DO
     BEGIN
          GetMem(p,512);
          AH := 2;
          DL := Ord(drive) - Ord('A');
          DH := 0;
          CH := 0;
          CL := 1;
          AL := 1;
          ES := Seg(p^);
          BX := Ofs(p^);
          Intr($13,reg);
          testeDrive := AH IN [0,6];
          FreeMem(p,512);
     END;
END;

PROCEDURE changeDrive;
VAR
   drive : Char;
   nbD : Byte;

BEGIN
     nbD := 0;
     FOR drive := 'A' TO 'F' DO
         IF testeDrive(drive) THEN
         BEGIN
              nbD := Succ(nbD);
              data[nbD] := drive + ':';
         END;
     IF nbD > 0 THEN
     BEGIN
          select := 1;
          data[1] := elargiADte(data[1],6);
          IF choix(xChoix,yChoix,6,nbD,select,data) THEN
             repert := compresse(data[select])
          ELSE
          BEGIN
               fin := True;
               select := 0;
          END;
     END;
END;


BEGIN
     sauvegarde(s);
     lastRep := '';
     repert := majuscule(repert);
     IF titre <> '' THEN
     BEGIN
          largeur := Length(titre) + 2;
          IF largeur < 24 THEN
             largeur := 24;
          IF posY + 14 <= absY THEN
             haut := posY
          ELSE
             haut := absY - 14;
          bas := haut + 14;
          IF posX + largeur <= absX THEN
             gauche := posX
          ELSE
             gauche := absX - largeur;
          droite := gauche + largeur + 1;
          centreRect(dlg.DRect,Length(titre)+2,5);
          WITH dlg DO
          BEGIN
               WITH DRect DO
               BEGIN
                    y1 := haut;
                    x1 := gauche;
                    y2 := bas;
                    x2 := droite;
               END;
               titre := '';
               DTyp := ombre2;
               clFond := coulDialogues;
               clTexte := coulTextes;
          END;
          ouvreDialogue(dlg);
          coulFond(coulDialogues);
          coulTexte(coulTextes);
          Gotoxy(gauche+2,haut+1);
          Write(graf,titre);
          xChoix := posX + (largeur DIV 2) - 9;
          yChoix := haut + 2;
     END
     ELSE
     BEGIN
          xChoix := posX;
          yChoix := posY;
     END;
     afficheRep := (fichier = '*.') AND (titre = '');
     fin := False;
     REPEAT
           IF litDir THEN
           BEGIN
                IF afficheRep THEN
                BEGIN
                     GotoXY(posX+2,posY-1);
                     Write(graf,Copy(blanche,1,long+1));
                     IF Length(repert) > long THEN
                        long := Length(repert);
                     GotoXY(posX+2,posY-1);
                     IF repert[Length(repert)] = '\' THEN
                        Write(graf,repert)
                     ELSE
                        Write(graf,repert+'\');
                END;
                
                IF choix(xChoix,yChoix,10,nbFic,select,data) THEN
                BEGIN
                     IF data[select][1] = #16 THEN
                     BEGIN
                          IF repert[Length(repert)] = '\' THEN
                           repert := repert + compresse(Copy(data[select],2,
                                  Length(data[select])-1))
                          ELSE
                           repert := repert+'\'+compresse(Copy(data[select],2,
                                  Length(data[select])-1));
                     END
                     ELSE
                         IF data[select][1] = #17 THEN
                         BEGIN
                              il := Length(repert);
                              WHILE NOT (repert[il] IN ['\',':']) DO
                                    il := il - 1;
                              IF repert[il] <> ':' THEN
                                 lastRep := #16 + ' '+ Copy(repert,il+1,
                                         Length(repert)-il);
                              il := Length(repert);
                              WHILE NOT (repert[il] IN ['\',':']) DO
                                    il := il - 1;
                              repert := Copy(repert,1,il);
                         END
                         ELSE
                         BEGIN
                              temp := compresse(data[select]);
                              IF temp[Length(temp)] <> ':' THEN
                              BEGIN
                                   fin := True;
                                   IF temp[1] <> '<' THEN
                                      fichier := temp
                                   ELSE
                                       fichier := ''
                              END
                              ELSE
                                  changeDrive;
                         END;
                END
                ELSE
                BEGIN
                     fin := True;
                     select := 0;
                END;
           END
           ELSE
               fin := True;
     UNTIL fin;
     choixFichier := select <> 0;
     fichier := majuscule(fichier);
     repert := majuscule(repert);
     IF select = 0 THEN
        fichier := '';
     IF repert[Length(repert)] <> '\' THEN
        repert := repert + '\';
     IF titre <> '' THEN
        fermeDialogue(dlg);
     restaure(s);
END;



END.