
z :: (Int , Maybe Int) -> [Bool] -> Maybe Int
z (i , Nothing) []       = Nothing
z (i , Just j) []        = Just j
z (i , Just j) (b : bs)  = z (i , Just j) bs
z (i , Nothing) (b : bs) = if b then Just i else z (i Prelude.+ 1 , Nothing) bs


zf :: [Bool] -> Maybe Int
zf bs = Prelude.snd $ DL.foldl delta (0 , Nothing) bs
  where
    delta :: (Int , Maybe Int) -> Bool -> (Int , Maybe Int)
    delta (i , Just j) _  = (i Prelude.+ 1 , Just j)
    delta (i , Nothing) b = if b then (i Prelude.+ 1 , Just i)
                                   else (i Prelude.+ 1 , Nothing)
-- DVS.foldl :: (a -> b -> a) -> a -> Vector n b -> a
-- DVS.foldr :: (a -> b -> b) -> b -> Vector n a -> b

--least _ [] = Nothing
--least i v  = if DVS.head v then Just i else least (i + 1) (DVS.tail v)

-- least :: KnownNat n => Vec n Bit -> Maybe (Finite n)
-- least f v = foldl f (Just i) _ = Just i

-- f (Just i) _ = Just i
-- f Nothing
