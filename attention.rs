#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! anyhow = "1"
//! chrono = { version="0.4", default-features= false, features = ["clock"] }
//! reqwest = { version = "0.11", default-features = false, features = ["rustls-tls", "json"] }
//! tokio = { version = "1.35", default-features = false, features = ["rt-multi-thread", "macros", "rt"] }
//! ```

use std::{collections::HashMap, fs, str::FromStr, sync::Arc};

use anyhow::Context;
use chrono::{Local, NaiveDate};
use reqwest::{Client, StatusCode};
use tokio::task::JoinSet;

// Configure here
const CHAT_ID: &str = "PUT YOUR CHAT ID HERE";
const API_TOKEN: &str = "PUT YOUR TOKEN HERE";

const LOGS_DIR: &str = "/var/uwuscan_log";

#[derive(Debug)]
struct Entry {
    date: NaiveDate,
    name: String,
    _ip: String,
    cartrige: u8,
    drum: u8,
}

impl FromStr for Entry {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut lines = s.lines().filter(|s| !s.is_empty());
        let entry = Entry {
            date: chrono::NaiveDateTime::parse_from_str(lines.next().unwrap(), "%c")?.into(),
            name: lines.next().unwrap()[14..].to_string(),
            _ip: lines.next().unwrap()[12..].to_string(),
            cartrige: lines.next().unwrap()[18..].trim_end_matches('%').parse()?,
            drum: lines.next().unwrap()[13..].trim_end_matches('%').parse()?, //12 18 13
        };
        Ok(entry)
    }
}
async fn notify_telegram(client: Arc<Client>, message: String) -> anyhow::Result<()> {
    let mut map = HashMap::new();
    map.insert("chat_id", CHAT_ID);
    map.insert("text", &message);

    let res = client
        .post(format!(
            "https://api.telegram.org/bot{}/sendMessage",
            API_TOKEN
        ))
        .json(&map)
        .send()
        .await?;

    match res.status() {
        StatusCode::OK => Ok(()),
        other_code => anyhow::bail!("Status code: {}", other_code),
    }
}

fn create_message(entry: Entry) -> String {
    if entry.cartrige < 20 || entry.drum < 20 {
        format!(
            "wawning: cawtwidge or dwum status in {} is less than 20%!!! please wepwace it!!! owo",
            entry.name
        )
    } else if entry.cartrige < 30 || entry.drum < 30 {
        format!("wawning: cawtwidge or dwum status in {} is less than 30%. wepwacement will be needed soon uwu~", entry.name)
    } else {
        format!("{} is fine uwu~", entry.name)
    }
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let dir = fs::read_dir(LOGS_DIR)?;
    let client = Arc::new(reqwest::Client::default());

    let mut jset = JoinSet::new();

    for file in dir
        .map_while(Result::ok)
        .filter(|de| de.file_name().to_string_lossy().ends_with(".txt"))
    {
        let client = Arc::clone(&client);
        let last_entry: Entry = fs::read_to_string(file.path())?
            .trim_end_matches("---\n")
            .split("---")
            .last()
            .context("Entry not found")?
            .trim()
            .parse()?;

        if Local::now().date_naive() != last_entry.date {
            continue;
        }
        let message = create_message(last_entry);

        jset.spawn(notify_telegram(Arc::clone(&client), message));
    }

    while let Some(res) = jset.join_next().await {
        if let Err(e) = res? {
            eprintln!("Failed to send request: {e}")
        }
    }

    Ok(())
}
