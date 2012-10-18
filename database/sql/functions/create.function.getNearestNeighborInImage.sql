--DROP FUNCTION getNearestNeighborInImage;

CREATE FUNCTION getNearestNeighborInImage(iimageid INT 
                                         ,ixtrsrcid INT
                                         ) RETURNS INT
BEGIN
  
  DECLARE oxtrsrcid INT;
  DECLARE itheta DOUBLE;
  
  SET itheta = 1;

  SELECT x2.id
    INTO oxtrsrcid
    FROM extractedsource x1
        ,extractedsource x2
   WHERE x1.id = ixtrsrcid
     AND x2.image = iimageid 
     AND x2.id <> ixtrsrcid
     AND x2.x * x1.x + x2.y * x1.y + x2.z * x1.z > COS(RADIANS(itheta))
     AND x2.zone BETWEEN CAST(FLOOR(x1.decl - itheta) AS INTEGER)
                     AND CAST(FLOOR(x1.decl + itheta) AS INTEGER)
     AND x2.ra BETWEEN x1.ra - alpha(itheta, x1.decl)
                   AND x1.ra + alpha(itheta, x1.decl)
     AND x2.decl BETWEEN x1.decl - itheta
                     AND x1.decl + itheta
     AND POWER((COS(RADIANS(x2.decl)) * COS(RADIANS(x2.ra))
               - COS(RADIANS(x1.decl)) * COS(RADIANS(x1.ra))
               ), 2)
        + POWER((COS(RADIANS(x2.decl)) * SIN(RADIANS(x2.ra))
                - COS(RADIANS(x1.decl)) * SIN(RADIANS(x1.ra))
                ), 2)
        + POWER((SIN(RADIANS(x2.decl))
                - SIN(RADIANS(x1.decl))
                ), 2) = (SELECT MIN(POWER((COS(RADIANS(x2.decl)) * COS(RADIANS(x2.ra))
                                          - COS(RADIANS(x1.decl)) * COS(RADIANS(x1.ra))
                                          ), 2)
                                   + POWER((COS(RADIANS(x2.decl)) * SIN(RADIANS(x2.ra))
                                           - COS(RADIANS(x1.decl)) * SIN(RADIANS(x1.ra))
                                           ), 2)
                                   + POWER((SIN(RADIANS(x2.decl))
                                           - SIN(RADIANS(x1.decl))
                                           ), 2)
                                   )
                           FROM extractedsource x1
                               ,extractedsource x2
                          WHERE x1.id = ixtrsrcid
                            AND x2.image = iimageid 
                            AND x2.id <> ixtrsrcid
                            AND x2.x * x1.x + x2.y * x1.y + x2.z * x1.z > COS(RADIANS(itheta))
                            AND x2.zone BETWEEN CAST(FLOOR(x1.decl - itheta) AS INTEGER)
                                            AND CAST(FLOOR(x1.decl + itheta) AS INTEGER)
                            AND x2.ra BETWEEN x1.ra - alpha(itheta, x1.decl)
                                          AND x1.ra + alpha(itheta, x1.decl)
                            AND x2.decl BETWEEN x1.decl - itheta
                                            AND x1.decl + itheta
                        )
  ;

  RETURN oxtrsrcid;

END;
