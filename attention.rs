#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! anyhow = "1"
//! chrono = { version="0.4", default-features= false, features = ["clock"] }
//! reqwest = { version = "0.11", default-features = false, features = ["rustls-tls", "json"] }
//! tokio = { version = "1.35", default-features = false, features = ["rt-multi-thread", "macros", "rt"] }
//! ```

use std::{collections::HashMap, env, fs, str::FromStr, sync::Arc};

use anyhow::Context;
use chrono::{Local, NaiveDate};
use reqwest::{Client, StatusCode};
use tokio::task::JoinSet;

#[derive(Debug)]
struct Entry {
    date: NaiveDate,
    _ip: String,
    cartrige: u8,
    drum: u8,
}

impl FromStr for Entry {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let (date, vals) = s[1..].split_once(']').unwrap();
        let vals: Vec<&str> = vals.trim().split(' ').collect();

        let date = chrono::NaiveDateTime::parse_from_str(date, "%c")?;

        let entry = Entry {
            date: date.into(),
            _ip: vals[0].into(),
            cartrige: vals[1].parse()?,
            drum: vals[2].parse()?,
        };
        Ok(entry)
    }
}
async fn notify_telegram(client: Arc<Client>, message: String) -> anyhow::Result<()> {
    let mut map = HashMap::new();
    map.insert("chat_id", env::var("CHAT_ID")?);
    map.insert("text", message);

    let res = client
        .post(format!(
            "https://api.telegram.org/bot{}/sendMessage",
            env::var("API_TOKEN")?
        ))
        .json(&map)
        .send()
        .await?;

    if StatusCode::OK != res.status() {
        anyhow::bail!("{}", res.text().await?)
    }

    Ok(())
}

fn create_message(entry: Entry, name: &str) -> String {
    if entry.cartrige < 20 || entry.drum < 20 {
        format!(
            "wawning: cawtwidge or dwum status in {name} is less than 20%!!! please wepwace it!!! owo",
        )
    } else if entry.cartrige < 30 || entry.drum < 30 {
        format!("wawning: cawtwidge or dwum status in {name} is less than 30%. wepwacement will be needed soon uwu~")
    } else {
        format!("{name} is fine uwu~")
    }
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let dir = fs::read_dir(env::var("LOGS_DIR")?).context("Could not read logs directory")?;
    let client = Arc::new(reqwest::Client::default());

    let mut jset = JoinSet::new();

    for file in dir
        .map_while(Result::ok)
        .filter(|de| de.file_name().to_string_lossy().ends_with(".log"))
    {
        let client = Arc::clone(&client);

        let file_name = file.file_name();
        let printer_name = file_name.to_str().unwrap().trim_end_matches(".log");

        let last_entry: Entry = fs::read_to_string(file.path())?
            .trim()
            .lines()
            .last()
            .context("Log entry not found")?
            .trim()
            .parse()
            .context(format!(
                "Could not parse log entry of {}",
                file.path().display()
            ))?;

        if Local::now().date_naive() != last_entry.date {
            continue;
        }
        let message = create_message(last_entry, printer_name);

        jset.spawn(notify_telegram(Arc::clone(&client), message));
    }

    while let Some(res) = jset.join_next().await {
        if let Err(e) = res? {
            eprintln!("Failed to send request: {e}")
        }
    }

    Ok(())
}
