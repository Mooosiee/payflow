module Main where
import Network.Wai.Handler.Warp (run)

main :: IO ()
main = do
  putStrLn "PayFlow starter: wire config, DB pool, migrations, logging and API."
  -- TODO: replace placeholder with real application wiring.
  run 8080 undefined
