use std::io::Read;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use std::time::Duration;
use ureq::tls::TlsConfig;

fn format_text(v: &serde_json::Value) -> Option<String> {
    let alerts = v["alerts"].as_array()?;
    if alerts.is_empty() {
        return None;
    }

    let env = v["commonLabels"]["env"].as_str().unwrap_or("");
    let status = alerts[0]["status"].as_str().unwrap_or("").to_uppercase();
    let alertname = alerts[0]["labels"]["alertname"].as_str().unwrap_or("");
    let summary = alerts[0]["annotations"]["summary"].as_str().unwrap_or("");
    let count = alerts.len();

    let mut instances: Vec<String> = Vec::new();
    for a in alerts {
        let inst = a["labels"]["instance"].as_str().unwrap_or("").to_string();
        if !inst.is_empty() && !instances.contains(&inst) {
            instances.push(inst);
        }
    }

    let head = if env.is_empty() {
        format!("{status} {alertname}")
    } else {
        format!("{env} {status} {alertname}")
    };

    let text = if count == 1 {
        if let Some(inst) = instances.first() {
            format!("{head} {inst}: {summary}")
        } else {
            format!("{head}: {summary}")
        }
    } else if instances.is_empty() {
        format!("{head} {count}x")
    } else {
        let shown: Vec<&str> = instances.iter().take(3).map(|s| s.as_str()).collect();
        let shown = shown.join(",");
        let rest = instances.len().saturating_sub(3);
        if rest > 0 {
            format!("{head} {count}x {shown} +{rest} more")
        } else {
            format!("{head} {count}x {shown}")
        }
    };

    Some(text)
}

fn main() {
    let base  = std::env::var("SMS_EAGLE_URL").unwrap();
    let token = std::env::var("SMS_EAGLE_TOKEN").unwrap();
    let to    = std::env::var("SMS_EAGLE_TO").unwrap();
    let port  = std::env::var("PORT").unwrap_or_else(|_| "9095".into());

    let agent = if std::env::var("SMS_EAGLE_INSECURE").unwrap_or_default() == "true" {
        println!("TLS verification disabled (SMS_EAGLE_INSECURE=true)");
        ureq::Agent::config_builder()
            .tls_config(
                TlsConfig::builder()
                    .disable_verification(true)
                    .build(),
            )
            .build()
            .new_agent()
    } else {
        ureq::Agent::new_with_defaults()
    };

    let running = Arc::new(AtomicBool::new(true));
    let r = running.clone();
    ctrlc::set_handler(move || {
        r.store(false, Ordering::SeqCst);
    })
    .expect("failed to set signal handler");

    let server = tiny_http::Server::http(format!("0.0.0.0:{port}")).unwrap();
    println!("listening on :{port}");

    while running.load(Ordering::SeqCst) {
        let mut req = match server.recv_timeout(Duration::from_millis(500)) {
            Ok(Some(req)) => req,
            Ok(None) => continue,
            Err(_) => break,
        };

        println!("<- {} {}", req.method(), req.url());

        if req.url() != "/alert" {
            let _ = req.respond(tiny_http::Response::empty(404));
            continue;
        }
        let mut body = String::new();
        req.as_reader().read_to_string(&mut body).ok();
        println!("   body: {body}");

        if let Ok(v) = serde_json::from_str::<serde_json::Value>(&body) {
            if let Some(text) = format_text(&v) {
                print!("   sms -> {text}");
                match agent.get(&format!("{base}/http_api/send_sms"))
                    .query("access_token", &token)
                    .query("to", &to)
                    .query("message", &text)
                    .call()
                {
                    Ok(_) => println!("  OK"),
                    Err(e) => println!("  FAIL: {e}"),
                }
            }
        }
        let _ = req.respond(tiny_http::Response::empty(200));
    }
    println!("shutting down");
}
