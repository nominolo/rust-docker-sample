use actix_web;
use env_logger;
use log;

use actix_web::{server, App, HttpRequest};
// use actix_web::http::{Method};
use log::info;
use std::env;

fn index(_req: &HttpRequest) -> &'static str {
    "Hello world!"
}

#[derive(Clone)]
pub struct Config {
    port: u16,
    bind_addr: String,
    prefix: String,
}

fn init_config_from_env() -> Result<Config, String> {
    let port = env::var("PORT")
        .unwrap_or("8080".to_string())
        .parse()
        .map_err(|_| "Could not parse port number")?;

    let bind_addr = env::var("BIND_ADDR").unwrap_or("127.0.0.1".to_string());

    let prefix = env::var("URL_PREFIX").unwrap_or("".to_string());

    Ok(Config {
        port,
        bind_addr,
        prefix,
    })
}

fn main() -> Result<(), String> {
    env_logger::Builder::from_env("HELLO_LOG")
        .filter(None, log::LevelFilter::Info)
        .init();

    let config = init_config_from_env()?;

    let bind_str = format!("{}:{}", config.bind_addr, config.port);

    info!("Listening on {}", &bind_str);

    server::new(move || {
        App::new()
            .prefix(config.prefix.as_ref())
            .resource("/", |r| r.get().f(index))
    }).bind(bind_str)
        .unwrap()
        .run();

    Ok(())
}

// use log;

// use log::info;

// fn main() {
//     info!("Test");
//     println!("Hello World!");
// }
