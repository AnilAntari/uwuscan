#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! anyhow = "1.0.79"
//! chrono = { version="0.4.33", default-features= false, features = ["clock"] }
//! ureq = { version = "2.9.5", features = ["json"] }
//! ```

use std::{collections::HashMap, env, fs, str::FromStr};

use anyhow::Context;
use chrono::{Local, NaiveDate};
use ureq::Agent;

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

        let dividers: &[char] = &['-', ','];
        let vals: Vec<&str> = vals.trim().split(dividers).map(str::trim).collect();

        let date = chrono::NaiveDateTime::parse_from_str(date, "%c")?;

        let entry = Entry {
            date: date.into(),
            _ip: vals[0].into(),
            cartrige: cut_str(vals[1], ':', '%').parse()?,
            drum: cut_str(vals[2], ':', '%').parse()?,
        };

        Ok(entry)
    }
}

fn cut_str(s: &str, start: char, end: char) -> &str {
    let start = s.find(start).unwrap() + 1;
    let end = s[start..].find(end).unwrap() + start;

    s[start..end].trim()
}

fn notify_telegram(agent: &Agent, message: String) -> anyhow::Result<()> {
    let mut map = HashMap::new();
    map.insert("chat_id", env::var("CHAT_ID")?);
    map.insert("text", message);

    let res = agent
        .get(&format!(
            "https://api.telegram.org/bot{}/sendMessage",
            env::var("API_TOKEN")?
        ))
        .send_json(&map)?;

    if 200 != res.status() {
        anyhow::bail!("{}", res.into_string()?)
    }

    Ok(())
}

fn create_message(entry: Entry, name: &str) -> String {
    if entry.cartrige < 20 || entry.drum < 20 {
        format!(
            "wawning: cawtwidge or dwum status in {name} is less than 20%!!! please wepwace it!!! owo",
        )
    } else if entry.cartrige < 30 || entry.drum < 30 {
        format!(
            "wawning: cawtwidge or dwum status in {name} is less than 30%. wepwacement will be needed soon uwu~"
        )
    } else {
        format!("{name} is fine uwu~")
    }
}

fn main() -> anyhow::Result<()> {
    let dir = fs::read_dir(env::var("LOGS_DIR")?).context("Could not read logs directory")?;
    let client = Agent::new();

    for file in dir
        .map_while(Result::ok)
        .filter(|de| de.file_name().to_string_lossy().ends_with(".log"))
    {
        let file_name = file.file_name();
        let printer_name = file_name.to_str().unwrap().trim_end_matches(".log");

        let log = fs::read_to_string(file.path())?;
        let raw_entry = log
            .trim()
            .lines()
            .next_back()
            .context(format!(
                "Log entry not found in {}, file may be empty",
                file.path().display()
            ))?
            .trim();

        if raw_entry.contains("Faiwed") {
            continue;
        }

        let last_entry: Entry = raw_entry.parse().context(format!(
            "Could not parse log entry of {}",
            file.path().display()
        ))?;

        if Local::now().date_naive() != last_entry.date {
            continue;
        }
        let message = create_message(last_entry, printer_name);

        notify_telegram(&client, message)?;
    }

    Ok(())
}
