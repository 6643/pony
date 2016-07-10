actor Main
  new create(env: Env) =>
    env.out.print(Hex.encode("111济公：第8集"))
    try env.out.print(Hex.decode("313131e6b58ee585acefbc9ae7acac38e99b86", env)) end
    

