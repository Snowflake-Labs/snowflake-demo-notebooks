"""Generate all PNG plots for the sfguide assets folder."""
import re
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.datasets import load_wine
from sklearn.model_selection import train_test_split, cross_val_score, cross_val_predict, learning_curve
from sklearn.preprocessing import StandardScaler, label_binarize
from sklearn.decomposition import PCA
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import confusion_matrix, classification_report, roc_curve, auc
import os

ASSETS = os.path.join(os.path.dirname(__file__), 'assets')
os.makedirs(ASSETS, exist_ok=True)

# ── Dataset ────────────────────────────────────────────────────────────────────
wine = load_wine()
df = pd.DataFrame(wine.data, columns=wine.feature_names)
df['cultivar'] = wine.target
df['cultivar_name'] = df['cultivar'].map({0: 'Cultivar 0', 1: 'Cultivar 1', 2: 'Cultivar 2'})

# ── Preprocessing ──────────────────────────────────────────────────────────────
X = df[list(wine.feature_names)].values
y = df['cultivar'].values
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled  = scaler.transform(X_test)

N_ESTIMATORS = 100
MAX_DEPTH     = 5
rf = RandomForestClassifier(n_estimators=N_ESTIMATORS, max_depth=MAX_DEPTH, random_state=42)
rf.fit(X_train_scaled, y_train)
y_pred = rf.predict(X_test_scaled)

# ── 1. Grouped Box Plots ───────────────────────────────────────────────────────
features = wine.feature_names
n_cols = 4
n_rows = (len(features) + n_cols - 1) // n_cols

fig, axes = plt.subplots(n_rows, n_cols, figsize=(18, n_rows * 3.5))
axes = axes.flatten()
colors = ['#29B5E8', '#FF6B35', '#4CAF50']

for i, feat in enumerate(features):
    ax = axes[i]
    data_by_class = [df[df['cultivar'] == c][feat].values for c in [0, 1, 2]]
    bp = ax.boxplot(data_by_class, patch_artist=True, tick_labels=['C0', 'C1', 'C2'],
                    medianprops=dict(color='black', linewidth=1.5))
    for patch, color in zip(bp['boxes'], colors):
        patch.set_facecolor(color)
        patch.set_alpha(0.7)
    ax.set_title(feat, fontsize=9, fontweight='bold')
    ax.set_xlabel('Cultivar')
    ax.tick_params(labelsize=8)
    ax.grid(True, alpha=0.3, axis='y')

for j in range(len(features), len(axes)):
    axes[j].set_visible(False)

fig.suptitle('Feature Distributions by Cultivar (Grouped Box Plots)', fontsize=14, fontweight='bold', y=1.01)
plt.tight_layout()
plt.savefig(f'{ASSETS}/grouped_box_plots.png', dpi=150, bbox_inches='tight')
plt.close()
print('saved grouped_box_plots.png')

# ── 2. Correlation Heatmap ─────────────────────────────────────────────────────
numeric_df = df[list(wine.feature_names)]
corr = numeric_df.corr()

fig, ax = plt.subplots(figsize=(13, 11))
sns.heatmap(corr, annot=True, fmt='.2f', cmap='coolwarm', center=0,
            linewidths=0.4, annot_kws={'size': 7},
            cbar_kws={'label': 'Pearson r', 'shrink': 0.8}, ax=ax)
ax.set_title('Feature Correlation Matrix (13 × 13)', fontsize=14, fontweight='bold', pad=12)
plt.xticks(rotation=45, ha='right', fontsize=8)
plt.yticks(rotation=0, fontsize=8)
plt.tight_layout()
plt.savefig(f'{ASSETS}/correlation_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print('saved correlation_heatmap.png')

# ── 3. Pairplot ────────────────────────────────────────────────────────────────
key_features = ['alcohol', 'flavanoids', 'color_intensity', 'proline',
                'od280/od315_of_diluted_wines']
pair_df = df[key_features + ['cultivar_name']].copy()
palette = {'Cultivar 0': '#29B5E8', 'Cultivar 1': '#FF6B35', 'Cultivar 2': '#4CAF50'}
g = sns.pairplot(pair_df, hue='cultivar_name', palette=palette,
                 plot_kws={'alpha': 0.6, 's': 25}, diag_kind='kde')
g.figure.suptitle('Pairplot — Key Features by Cultivar', y=1.02, fontsize=13, fontweight='bold')
plt.tight_layout()
g.figure.savefig(f'{ASSETS}/pairplot_key_features.png', dpi=150, bbox_inches='tight')
plt.close()
print('saved pairplot_key_features.png')

# ── 4. PCA Scores Panel ────────────────────────────────────────────────────────
X_full = df[list(wine.feature_names)].values
y_full = df['cultivar'].values
X_full_scaled = scaler.transform(X_full)

pca = PCA(n_components=2, random_state=42)
X_pca = pca.fit_transform(X_full_scaled)
var_explained = pca.explained_variance_ratio_ * 100

train_idx, _ = train_test_split(np.arange(len(X_full)), test_size=0.2, random_state=42, stratify=y_full)
split_labels = np.full(len(X_full), 'Test', dtype=object)
split_labels[train_idx] = 'Train'

pca_df = pd.DataFrame({'PC1': X_pca[:, 0], 'PC2': X_pca[:, 1],
                        'cultivar': y_full, 'split': split_labels})

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

for split, color, size, alpha, zorder in [('Test', '#FF6B35', 70, 0.85, 2), ('Train', '#29B5E8', 50, 0.70, 3)]:
    mask = pca_df['split'] == split
    axes[0].scatter(pca_df.loc[mask, 'PC1'], pca_df.loc[mask, 'PC2'],
                    color=color, label=f'{split} (n={mask.sum()})',
                    s=size, alpha=alpha, edgecolors='white', linewidths=0.5, zorder=zorder)
axes[0].set_title('PCA Scores — Train / Test Split', fontsize=12, fontweight='bold')
axes[0].set_xlabel(f'PC1 ({var_explained[0]:.1f}% var)')
axes[0].set_ylabel(f'PC2 ({var_explained[1]:.1f}% var)')
axes[0].legend(title='Split', fontsize=9)
axes[0].grid(True, alpha=0.3)

class_colors = {0: '#29B5E8', 1: '#FF6B35', 2: '#4CAF50'}
for cls, color in class_colors.items():
    mask = pca_df['cultivar'] == cls
    axes[1].scatter(pca_df.loc[mask, 'PC1'], pca_df.loc[mask, 'PC2'],
                    color=color, label=f'{wine.target_names[cls]} (n={mask.sum()})',
                    s=50, alpha=0.75, edgecolors='white', linewidths=0.5)
axes[1].set_title('PCA Scores — Cultivar Class', fontsize=12, fontweight='bold')
axes[1].set_xlabel(f'PC1 ({var_explained[0]:.1f}% var)')
axes[1].set_ylabel(f'PC2 ({var_explained[1]:.1f}% var)')
axes[1].legend(title='Cultivar', fontsize=9)
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig(f'{ASSETS}/pca_scores_panel.png', dpi=150, bbox_inches='tight')
plt.close()
print('saved pca_scores_panel.png')

# ── 5. Confusion Matrix ────────────────────────────────────────────────────────
cm = confusion_matrix(y_test, y_pred)

fig, ax = plt.subplots(figsize=(6, 5))
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues',
            xticklabels=wine.target_names, yticklabels=wine.target_names,
            linewidths=0.5, cbar_kws={'label': 'Count'}, ax=ax)
ax.set_title('Confusion Matrix', fontsize=13, fontweight='bold', pad=12)
ax.set_xlabel('Predicted Label', fontsize=11)
ax.set_ylabel('True Label', fontsize=11)
plt.tight_layout()
plt.savefig(f'{ASSETS}/confusion_matrix.png', dpi=150, bbox_inches='tight')
plt.close()
print('saved confusion_matrix.png')

# ── 6. Feature Importances ─────────────────────────────────────────────────────
importances  = rf.feature_importances_
feature_names = wine.feature_names
sorted_idx   = np.argsort(importances)

fig, ax = plt.subplots(figsize=(8, 7))
bars = ax.barh(range(len(sorted_idx)), importances[sorted_idx], align='center',
               color='#29B5E8', alpha=0.8, edgecolor='white')
ax.set_yticks(range(len(sorted_idx)))
ax.set_yticklabels([feature_names[i] for i in sorted_idx], fontsize=10)
ax.set_xlabel('Feature Importance (Mean Decrease in Impurity)', fontsize=11)
ax.set_title('Random Forest Feature Importances', fontsize=13, fontweight='bold')
ax.grid(True, axis='x', alpha=0.3)
for bar, val in zip(bars, importances[sorted_idx]):
    ax.text(val + 0.002, bar.get_y() + bar.get_height() / 2, f'{val:.3f}', va='center', fontsize=8)
plt.tight_layout()
plt.savefig(f'{ASSETS}/feature_importances.png', dpi=150, bbox_inches='tight')
plt.close()
print('saved feature_importances.png')

# ── 7. ROC Curves ─────────────────────────────────────────────────────────────
y_bin = label_binarize(y, classes=[0, 1, 2])
X_scaled_all = scaler.transform(X)
_, X_test_all, _, y_test_bin = train_test_split(X_scaled_all, y_bin, test_size=0.2, random_state=42, stratify=y)
y_score    = rf.predict_proba(X_test_scaled)
y_cv_score = cross_val_predict(
    RandomForestClassifier(n_estimators=N_ESTIMATORS, max_depth=MAX_DEPTH, random_state=42),
    X_scaled_all, y, cv=5, method='predict_proba'
)

roc_colors = ['#29B5E8', '#FF6B35', '#4CAF50']
fig, axes = plt.subplots(1, 2, figsize=(14, 6))
panels = [(y_score, y_test_bin, 'ROC Curves — Test Set'),
          (y_cv_score, y_bin,   'ROC Curves — 5-Fold CV (Out-of-Fold)')]

for ax, (scores, labels, title) in zip(axes, panels):
    for i, (cls_name, color) in enumerate(zip(wine.target_names, roc_colors)):
        fpr, tpr, _ = roc_curve(labels[:, i], scores[:, i])
        roc_auc = auc(fpr, tpr)
        ax.plot(fpr, tpr, color=color, linewidth=2, label=f'{cls_name} (AUC = {roc_auc:.3f})')
        ax.fill_between(fpr, tpr, alpha=0.1, color=color)
    ax.plot([0, 1], [0, 1], 'k--', linewidth=1, alpha=0.5, label='Random classifier')
    ax.set_xlim([0.0, 1.0]); ax.set_ylim([0.0, 1.05])
    ax.set_xlabel('False Positive Rate', fontsize=11)
    ax.set_ylabel('True Positive Rate', fontsize=11)
    ax.set_title(title, fontsize=13, fontweight='bold')
    ax.legend(loc='lower right', fontsize=10)
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig(f'{ASSETS}/roc_curves.png', dpi=150, bbox_inches='tight')
plt.close()
print('saved roc_curves.png')

# ── 8. Learning Curve ─────────────────────────────────────────────────────────
train_sizes, train_scores, val_scores = learning_curve(
    RandomForestClassifier(n_estimators=N_ESTIMATORS, max_depth=MAX_DEPTH, random_state=42),
    scaler.transform(X), y, cv=5, scoring='accuracy',
    train_sizes=np.linspace(0.1, 1.0, 10), n_jobs=-1
)
train_mean = train_scores.mean(axis=1); train_std = train_scores.std(axis=1)
val_mean   = val_scores.mean(axis=1);   val_std   = val_scores.std(axis=1)

fig, ax = plt.subplots(figsize=(8, 5))
ax.plot(train_sizes, train_mean, 'o-', color='#29B5E8', linewidth=2, label='Training accuracy')
ax.fill_between(train_sizes, train_mean - train_std, train_mean + train_std, alpha=0.15, color='#29B5E8')
ax.plot(train_sizes, val_mean, 's-', color='#FF6B35', linewidth=2, label='CV accuracy')
ax.fill_between(train_sizes, val_mean - val_std, val_mean + val_std, alpha=0.15, color='#FF6B35')
ax.set_xlabel('Training Set Size', fontsize=11)
ax.set_ylabel('Accuracy', fontsize=11)
ax.set_title(f'Learning Curve — Random Forest (n_estimators={N_ESTIMATORS}, max_depth={MAX_DEPTH})',
             fontsize=13, fontweight='bold')
ax.legend(fontsize=10); ax.set_ylim([0.7, 1.05]); ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig(f'{ASSETS}/learning_curve.png', dpi=150, bbox_inches='tight')
plt.close()
print('saved learning_curve.png')

print('\nAll plots saved to', ASSETS)
