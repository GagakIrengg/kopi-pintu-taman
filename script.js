const API_BASE = "";

const MENU = [
  {
    cat: "Signature Coffee",
    items: [
      {
        name: "Kopi Pintu Taman",
        price: 25000,
        shortDesc: "Espresso, creme brulee, dan susu creamy.",
        fullDesc: "Espresso dengan perpaduan sirup creme brulee dan susu, menghadirkan rasa manis lembut yang khas.",
        strength: 3,
        sweet: 4,
        badges: ["Ice/Hot", "Recommended"]
      },
      {
        name: "Kopi Creamy Aren",
        price: 23000,
        shortDesc: "Espresso, susu, dan gula aren creamy.",
        fullDesc: "Perpaduan espresso, susu, dan gula aren dengan rasa creamy manis yang lembut dan seimbang.",
        strength: 4,
        sweet: 4,
        badges: ["Ice/Hot", "Recommended"]
      },
      {
        name: "Kopi Foamy Aren",
        price: 25000,
        shortDesc: "Espresso, gula aren, dan foam lembut.",
        fullDesc: "Espresso dan susu dengan manis khas gula aren, dilengkapi lapisan foam yang lembut.",
        strength: 3,
        sweet: 5,
        badges: ["Ice", "Recommended"]
      },
      {
        name: "Roasted Almond Latte",
        price: 25000,
        shortDesc: "Latte dengan sirup roasted almond.",
        fullDesc: "Latte creamy dengan aroma roasted almond yang manis dan cita rasa yang lembut.",
        strength: 3,
        sweet: 5,
        badges: ["Ice/Hot"]
      },
      {
        name: "Butterscotch Cream Latte",
        price: 30000,
        shortDesc: "Latte dengan syrup butterscotch dengan foam.",
        fullDesc: "Espresso dengan butterscotch syrup dan susu creamy, dilengkapi lapisan foam dan pecahan biskuit biscoff.",
        strength: 3,
        sweet: 5,
        badges: ["Ice/Hot", "New"]
      }
    ]
  },

  {
    cat: "Black Coffee",
    items: [
      {
        name: "Mont Blanc",
        price: 30000,
        shortDesc: "Black coffee dengan orange juice.",
        fullDesc: "Black coffee berbasis americano dengan sentuhan orange juice dan foam lembut yang segar.",
        strength: 5,
        sweet: 2,
        badges: ["Ice", "New"]
      },
      {
        name: "Kopi Apel",
        price: 22000,
        shortDesc: "Black coffee dengan apple syrup.",
        fullDesc: "Black coffee dengan rasa ringan dan sentuhan manis segar dari apple syrup.",
        strength: 5,
        sweet: 3,
        badges: ["Ice"]
      },
      {
        name: "Kopi Berry",
        price: 22000,
        shortDesc: "Black coffee dengan berry puree.",
        fullDesc: "Perpaduan black coffee dengan berry puree yang memberikan sedikit rasa manis.",
        strength: 5,
        sweet: 2,
        badges: ["Ice"]
      }
    ]
  },

  {
    cat: "Regular Coffee",
    items: [
      {
        name: "Americano",
        price: 20000,
        shortDesc: "Espresso dengan air panas.",
        fullDesc: "Espresso dengan air panas, menghasilkan rasa kopi yang bold dan ringan.",
        strength: 5,
        sweet: 0,
        badges: ["Ice/Hot"]
      },
      {
        name: "Cafe Latte",
        price: 23000,
        shortDesc: "Espresso dan susu.",
        fullDesc: "Perpaduan antara Espresso dan susu.",
        strength: 4,
        sweet: 1,
        badges: ["Ice/Hot"]
      },
      {
        name: "Cappuccino",
        price: 23000,
        shortDesc: "Espresso, susu, dan foam.",
        fullDesc: "Perpaduan antara Espresso dan susu lalu di steam untuk menciptakan foam.",
        strength: 4,
        sweet: 1,
        badges: ["Ice/Hot"]
      },
      {
        name: "Asian Dolce",
        price: 23000,
        shortDesc: "Milk coffee manis creamy.",
        fullDesc: "Espresso creamy dengan sentuhan rasa manis khas Asian-style milk coffee.",
        strength: 3,
        sweet: 3,
        badges: ["Ice/Hot"]
      },
      {
        name: "Cafe Mocha",
        price: 25000,
        shortDesc: "Espresso dengan cokelat.",
        fullDesc: "Espresso dengan perpaduan cokelat powder dan susu.",
        strength: 4,
        sweet: 2,
        badges: ["Ice/Hot"]
      },
      {
        name: "Vanilla Latte",
        price: 25000,
        shortDesc: "Espresso, Susu dan sirup vanilla.",
        fullDesc: "Perpaduan Espresso, Susu, dan sirup vanilla.",
        strength: 2,
        sweet: 4,
        badges: ["Ice/Hot"]
      },
      {
        name: "Caramel Latte",
        price: 25000,
        shortDesc: "Espresso, Susu dan sirup caramel.",
        fullDesc: "Perpauan Espresso dan susu dengan rasa dari sirup caramel.",
        strength: 2,
        sweet: 4,
        badges: ["Ice/Hot"]
      },
      {
        name: "Hazelnut Latte",
        price: 25000,
        shortDesc: "Espresso, Susu dan sirup caramel.",
        fullDesc: "Perpaduan Espresso dan susu dengan rasa kacang Hazelnut.",
        strength: 2,
        sweet: 4,
        badges: ["Ice/Hot"]
      },
      {
        name: "Butterscotch Latte",
        price: 25000,
        shortDesc: "Espresso, Susu dan sirup Butterscotch.",
        fullDesc: "Perpauan Espresso dan susu dengan rasa dari sirup butterscotch.",
        strength: 2,
        sweet: 5,
        badges: ["Ice/Hot"]
      }
    ]
  },

  {
    cat: "Matcha",
    items: [
      {
        name: "Matcha Latte",
        price: 23000,
        shortDesc: "Matcha dengan perpaduan susu.",
        fullDesc: "Perpaduan antara Matcha Powder dengan Susu yang menciptakan rasa creamy dan lembut.",
        strength: 0,
        sweet: 2,
        badges: ["Ice/Hot"]
      },
      {
        name: "Matcha Espresso",
        price: 28000,
        shortDesc: "Matcha dengan espresso.",
        fullDesc: "Perpaduan matcha dan espresso dengan rasa unik yang bold dan creamy.",
        strength: 4,
        sweet: 2,
        badges: ["Ice", "New"]
      },
      {
        name: "Strawberry Matcha",
        price: 28000,
        shortDesc: "Matcha dengan strawberry.",
        fullDesc: "Matcha dengan sentuhan rasa strawberry yang manis dan segar.",
        strength: 0,
        sweet: 4,
        badges: ["Ice", "New"]
      }
    ]
  },

  {
    cat: "Non Coffee",
    items: [
      {
        name: "Chocolate",
        price: 23000,
        shortDesc: "Dark Chocolate.",
        fullDesc: "Minuman Coklat dengan paduan susu yang mencintapakan rasa pahit dan manis yang seimbang.",
        strength: 1,
        sweet: 2,
        badges: ["Ice/Hot"]
      },
      {
        name: "Thai Tea",
        price: 20000,
        shortDesc: "Minuman teh susu khas thailand.",
        fullDesc: "Teh Thailand autentik dengan rasa manis, creamy, dan aroma teh yang khas.",
        strength: 0,
        sweet: 4,
        badges: ["Ice"]
      },
      {
        name: "Strawberry Milk",
        price: 22000,
        shortDesc: "Susu strawberry segar.",
        fullDesc: "Perpaduan Susu dengan strawberry puree yang creamy.",
        strength: 0,
        sweet: 4,
        badges: ["Ice", "Recommended"]
      },
      {
        name: "Manggo Yakult",
        price: 20000,
        shortDesc: "Minuman mangga segar dengan yakult.",
        fullDesc: "Perpaduan miinuman mangga segar dengan yakult yang manis, asam, dan menyegarkan.",
        strength: 0,
        sweet: 4,
        badges: ["Ice"]
      },
      {
        name: "Lychee Yakult",
        price: 20000,
        shortDesc: "Minuman leci segar dengan yakult.",
        fullDesc: "Kombinasi buah leci manis dengan yakult yang segar dan sedikit asam.",
        strength: 0,
        sweet: 3,
        badges: ["Ice"]
      },
      {
        name: "Lemon Tea",
        price: 18000,
        shortDesc: "Teh lemon segar manis dan asam.",
        fullDesc: "Teh pilihan dengan rasa lemon segar yang menghadirkan rasa manis dan asam seimbang.",
        strength: 0,
        sweet: 3,
        badges: ["Ice/Hot"]
      },
      {
        name: "Lychee Tea",
        price: 18000,
        shortDesc: "Teh leci manis dan menyegarkan.",
        fullDesc: "Teh segar dengan rasa leci manis yang ringan dan cocok dinikmati kapan saja.",
        strength: 0,
        sweet: 4,
        badges: ["Ice/Hot", "Recommended"]
      },
      {
        name: "Lemongrass Tea",
        price: 18000,
        shortDesc: "Teh serai aromatik segar.",
        fullDesc: "Teh serai dengan aroma khas yang menenangkan serta rasa rempah yang ringan dan menyegarkan.",
        strength: 0,
        sweet: 3,
        badges: ["Ice/Hot"]
      }
    ]
  },

  {
    cat: "Snacks",
    items: [
      {
        name: "Donut Kampung",
        price: 6000,
        shortDesc: "Donat empuk dengan gula halus.",
        fullDesc: "Donat empuk dengan taburan gula halus, sederhana dan selalu nikmat.",
        strength: 0,
        sweet: 0,
        badges: []
      },
      {
        name: "Pisang Goreng ",
        price: 15000,
        shortDesc: "Pisang Goreng dengan Taburan Gula Aren.",
        fullDesc: "5 Pisang Goreng yang disajikan dengan Taburan Bubuk Gula Aren yang manis.",
        strength: 0,
        sweet: 0,
        badges: []
      },
      {
        name: "Cireng Bumbu Rujak",
        price: 15000,
        shortDesc: "Cireng kenyal dengan bumbu rujak.",
        fullDesc: "Cireng goreng kenyal disajikan dengan bumbu rujak pedas manis yang khas.",
        strength: 0,
        sweet: 0,
        badges: ["Recommended"]
      },
      {
        name: "French Fries",
        price: 18000,
        shortDesc: "Kentang goreng renyah.",
        fullDesc: "Kentang goreng renyah dengan rasa gurih klasik.",
        strength: 0,
        sweet: 0,
        badges: []
      },
      {
        name: "Mix Platter",
        price: 25000,
        shortDesc: "Kentang, Sosis, Nugget dalam 1 Platter.",
        fullDesc: "Perpaduan kentang goreng, sosis, dan nugget dalam satu porsi praktis untuk dinikmati bersama.",
        strength: 0,
        sweet: 0,
        badges: ["Recommended"]
      },
      {
        name: "Chicken Wings",
        price: 23000,
        shortDesc: "Sayap ayam juicy.",
        fullDesc: "Sayap ayam dengan rasa gurih dan juicy.",
        strength: 0,
        sweet: 0,
        badges: []
      }
    ]
  },

  {
    cat: "Pizza",
    items: [
      {
        name: "Pepperoni",
        price: 35000,
        shortDesc: "Pizza pepperoni dan keju.",
        fullDesc: "Pizza dengan topping pepperoni gurih dan keju leleh.",
        strength: 0,
        sweet: 0,
        badges: []
      },
      {
        name: "Supreme Cheese",
        price: 35000,
        shortDesc: "Pizza keju creamy menggunakan keju Mozarela.",
        fullDesc: "Pizza dengan topping keju Mozarela yang melimpah dan rasa lumer saat dimakan.",
        strength: 0,
        sweet: 0,
        badges: []
      },
      {
        name: "Pizza Blackpepper",
        price: 35000,
        shortDesc: "Pizza dengan saus lada hitam dan keju .",
        fullDesc: "Pizza dengan rasa gurih blackpaper yang dipadukan dengan keju.",
        strength: 0,
        sweet: 0,
        badges: []
      },
    ]
  },

  {
    cat: "Rice Bowl",
    items: [
      {
        name: "Chicken Matah",
        price: 33000,
        shortDesc: "Rice Bowl Ayam sambal matah.",
        fullDesc: "Ayam dengan sambal matah segar dan nasi hangat.",
        strength: 0,
        sweet: 0,
        badges: ["New"]
      },
      {
        name: "Chicken Rendang",
        price: 33000,
        shortDesc: "Rice Bowl Ayam dengan Bumbu Rendang.",
        fullDesc: "Ayam dengan bumbu rendang dengan kerupuk dan nasi hangat.",
        strength: 0,
        sweet: 0,
        badges: ["New"]
      },
      {
        name: "Chicken Karage",
        price: 33000,
        shortDesc: "Rice Bowl Ayam Karage.",
        fullDesc: "Ayam karage gurih dengan nasi hangat.",
        strength: 0,
        sweet: 0,
        badges: ["New"]
      },
      {
        name: "Beef Blackpepper",
        price: 33000,
        shortDesc: "Rice Bowl Daging bumbu blackpepper.",
        fullDesc: "Daging sapi dengan saus blackpepper dan nasi hangat.",
        strength: 0,
        sweet: 0,
        badges: ["New"]
      },
      {
        name: "Beef Yakiniku",
        price: 33000,
        shortDesc: "Rice Bowl dengan Daging bumbu Yakiniku.",
        fullDesc: "Daging sapi dengan saus yakiniku dan nasi hangat.",
        strength: 0,
        sweet: 0,
        badges: ["New"]
      }
    ]
  }
];

// Flatten menu names
const allMenuNames = MENU.flatMap(c => c.items.map(i => i.name));

// Modal detail menu
const detailOverlay = document.getElementById("detail-overlay");

function createBar(level) {
  return "▰".repeat(level) + "▱".repeat(5 - level);
}

function openMenuDetail(item) {
  document.getElementById("detail-name").textContent = item.name;
  document.getElementById("detail-price").textContent =
    `Rp ${item.price.toLocaleString("id-ID")}`;

  document.getElementById("detail-desc").textContent =
    item.fullDesc;

  const levels = document.getElementById("detail-levels");
  const strengthWrap = document.getElementById("strength-wrap");
  const sweetWrap = document.getElementById("sweet-wrap");

  // strength
  if (item.strength > 0) {
    strengthWrap.style.display = "block";
    document.getElementById("detail-strength").textContent =
      createBar(item.strength);
  } else {
    strengthWrap.style.display = "none";
  }

  // sweet
  if (item.sweet > 0) {
    sweetWrap.style.display = "block";
    document.getElementById("detail-sweet").textContent =
      createBar(item.sweet);
  } else {
    sweetWrap.style.display = "none";
  }

  // hide all if both zero
  if (item.strength > 0 || item.sweet > 0) {
    levels.style.display = "block";
  } else {
    levels.style.display = "none";
  }

  detailOverlay.classList.add("active");
}

document.getElementById("detail-close").onclick = () =>
  detailOverlay.classList.remove("active");

detailOverlay.addEventListener("click", e => {
  if (e.target === detailOverlay) {
    detailOverlay.classList.remove("active");
  }
});

// ============================================================
// Render menu utama  (jalan langsung saat halaman dibuka)
// ============================================================
const container = document.getElementById("menu-container");

MENU.forEach(cat => {
  const h = document.createElement("h2");
  h.className = "category-title";
  h.textContent = cat.cat;
  container.appendChild(h);

  cat.items.forEach(item => {
    const icon = ["Snacks"].includes(cat.cat)
      ? "🍟"
      : ["Pizza"].includes(cat.cat)
      ? "🍕"
      : ["Rice Bowl"].includes(cat.cat)
      ? "🍚"
      : ["Matcha"].includes(cat.cat)
      ? "🍵"
      : ["Non Coffee"].includes(cat.cat)
      ? "🥤"
      : "☕";

    const div = document.createElement("div");
    div.className = "menu-item";

    const badgeHtml = item.badges?.length
      ? `<div class="menu-badges">
          ${item.badges.map(b => `<span class="badge">${b}</span>`).join("")}
         </div>`
      : "";

    div.innerHTML = `
      <span class="menu-icon">${icon}</span>
      <div class="menu-info">
        <div class="menu-name-row">
          <div class="menu-name">${item.name}</div>
          ${badgeHtml}
        </div>
        <div class="menu-price">Rp ${item.price.toLocaleString("id-ID")}</div>
        <div class="menu-desc">${item.shortDesc}</div>
      </div>`;

    div.addEventListener("click", () => openMenuDetail(item));

    container.appendChild(div);
  });
});

// ============================================================
// Rekomendasi (dari hasil SAW via API)
// ============================================================
const recContainer = document.getElementById("rec-container");
const allItems = MENU.flatMap(c => c.items);

async function loadRecommendations() {
  try {
    const res = await fetch(`${API_BASE}/api/recommendations`);
    if (!res.ok) throw new Error("gagal ambil rekomendasi");
    const data = await res.json();

    // ambil yang ditandai recommended; kalau kosong, pakai 3 teratas
    let recs = data.filter(d => d.is_recommended);
    if (recs.length === 0) recs = data.slice(0, 3);

    if (recs.length === 0) {
      // Fallback terakhir: belum ada hasil SAW sama sekali.
      recContainer.innerHTML =
        '<p style="color:#a1887f;font-size:.85rem">' +
        'Rekomendasi belum tersedia.</p>';
      return;
    }

    recContainer.innerHTML = "";
    recs.forEach(r => {
      const item = allItems.find(i => i.name === r.menu_name);
      const price = item
        ? `Rp ${item.price.toLocaleString("id-ID")}`
        : "";

      const div = document.createElement("div");
      div.className = "rec-card";
      div.innerHTML = `
        <div class="rec-icon">☕</div>
        <div class="rec-badge">👍 Best</div>
        <div class="rec-name">${r.menu_name}</div>
        <div class="rec-price">${price}</div>
      `;
      if (item) {
        div.addEventListener("click", () => openMenuDetail(item));
      }
      recContainer.appendChild(div);
    });
  } catch (err) {
    console.error(err);
    recContainer.innerHTML =
      '<p style="color:#a1887f;font-size:.85rem">' +
      'Rekomendasi belum tersedia.</p>';
  }
}

loadRecommendations();


// Modal
const overlay = document.getElementById("modal-overlay");
document.getElementById("fab-review").onclick = () => overlay.classList.add("active");
document.getElementById("modal-close").onclick = () => overlay.classList.remove("active");
overlay.addEventListener("click", e => { if (e.target === overlay) overlay.classList.remove("active"); });

// Dropdown search
const searchInput = document.getElementById("menu-search");
const dropdownList = document.getElementById("dropdown-list");
const selectedMenu = document.getElementById("selected-menu");

function renderDropdown(filter = "") {
  const f = filter.toLowerCase();
  const matches = allMenuNames.filter(n => n.toLowerCase().includes(f));
  dropdownList.innerHTML = matches.map(n => `<li>${n}</li>`).join("");
  dropdownList.classList.toggle("show", matches.length > 0 && filter.length > 0);
}
searchInput.addEventListener("input", () => { renderDropdown(searchInput.value); selectedMenu.value = ""; });
searchInput.addEventListener("focus", () => { if (searchInput.value) renderDropdown(searchInput.value); });
dropdownList.addEventListener("click", e => {
  if (e.target.tagName === "LI") {
    searchInput.value = e.target.textContent;
    selectedMenu.value = e.target.textContent;
    dropdownList.classList.remove("show");
  }
});
document.addEventListener("click", e => { if (!e.target.closest(".dropdown-wrapper")) dropdownList.classList.remove("show"); });

// Star rating
const starContainer = document.getElementById("star-rating");
const ratingInput = document.getElementById("rating-value");
starContainer.querySelectorAll("span").forEach(star => {
  star.addEventListener("click", () => {
    const val = parseInt(star.dataset.val);
    ratingInput.value = val;
    starContainer.querySelectorAll("span").forEach(s => {
      s.textContent = parseInt(s.dataset.val) <= val ? "★" : "☆";
      s.classList.toggle("active", parseInt(s.dataset.val) <= val);
    });
  });
});

// Submit
document.getElementById("review-form").addEventListener("submit", async e => {
  e.preventDefault();
  const msg = document.getElementById("form-msg");
  const menu_name = selectedMenu.value;
  const rating = parseInt(ratingInput.value);
  const review_text = document.getElementById("review-text").value.trim();

  if (!menu_name) { msg.textContent = "Pilih menu terlebih dahulu."; msg.className = "form-msg error"; return; }
  if (!rating) { msg.textContent = "Pilih rating terlebih dahulu."; msg.className = "form-msg error"; return; }

  try {
    const res = await fetch(`${API_BASE}/api/reviews`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ menu_name, rating, review_text }),
    });
    if (!res.ok) throw new Error("Gagal mengirim review");
    msg.textContent = "✅ Review berhasil dikirim!";
    msg.className = "form-msg success";
    // Reset
    searchInput.value = ""; selectedMenu.value = ""; ratingInput.value = "";
    document.getElementById("review-text").value = "";
    starContainer.querySelectorAll("span").forEach(s => { s.textContent = "☆"; s.classList.remove("active"); });
    setTimeout(() => { overlay.classList.remove("active"); msg.textContent = ""; }, 1500);
  } catch (err) {
    msg.textContent = "❌ " + err.message;
    msg.className = "form-msg error";
  }
});