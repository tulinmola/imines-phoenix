import "phoenix_html"

import Realtime from "./realtime"
import TileManager from "./tile_manager"
import ViewController from "./view_controller"
import "./menu"

$(() => {
  const rt = new Realtime({token: window.userToken}),
        tiles = new TileManager(rt),
        view = new ViewController("main", tiles);
  window.view = view;
});
