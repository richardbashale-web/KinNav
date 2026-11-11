import { useEffect, useState } from 'react';

interface Report {
  id: string;
  type: string;
  lat: number;
  lng: number;
  description: string;
  severity: string;
  status: string;
  created_at: string;
  votes_confirm: number;
  votes_deny: number;
}

const typeNames: Record<string, string> = {
  accident: 'Accident',
  works: 'Travaux',
  jam: 'Bouchon',
  barrier: 'Barrière',
  flood: 'Inondation',
  clear: 'Route dégagée',
};

export default function App() {
  const [reports, setReports] = useState<Report[]>([]);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);

  async function loadReports() {
    setLoading(true);
    setError('');
    try {
      const response = await fetch('/api/v1/traffic/reports');
      if (!response.ok) throw new Error(`Erreur serveur (${response.status})`);
      const payload: { reports: Report[] } = await response.json();
      setReports(payload.reports);
    } catch (reason) {
      setError(reason instanceof Error ? reason.message : 'Impossible de charger les signalements.');
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    void loadReports();
  }, []);

  const todayCount = reports.filter(
    (report) => new Date(report.created_at).toDateString() === new Date().toDateString(),
  ).length;

  return (
    <main className="shell">
      <header className="topbar">
        <div>
          <p className="eyebrow">KINSHASA · OPÉRATIONS</p>
          <h1>Tableau de bord</h1>
        </div>
        <button onClick={() => void loadReports()} disabled={loading}>
          {loading ? 'Chargement…' : 'Actualiser'}
        </button>
      </header>
      <section className="metrics" aria-label="Résumé">
        <article><span>Signalements visibles</span><strong>{reports.length}</strong></article>
        <article><span>Signalements aujourd’hui</span><strong>{todayCount}</strong></article>
        <article><span>À examiner</span><strong>{reports.filter((item) => item.status === 'active').length}</strong></article>
      </section>
      <section className="panel">
        <div className="panel-heading">
          <div><p className="eyebrow">COMMUNAUTÉ</p><h2>Signalements</h2></div>
          <span className="read-only">Consultation seule</span>
        </div>
        {error && <p className="error" role="alert">{error}</p>}
        {!error && loading && <p className="empty">Chargement des données…</p>}
        {!error && !loading && reports.length === 0 && (
          <p className="empty">Aucun signalement enregistré.</p>
        )}
        {!loading && reports.length > 0 && (
          <div className="table-wrap">
            <table>
              <thead><tr><th>Type</th><th>Description</th><th>Emplacement</th><th>Gravité</th><th>Votes</th><th>État</th></tr></thead>
              <tbody>
                {reports.map((report) => (
                  <tr key={report.id}>
                    <td><span className={`tag ${report.type}`}>{typeNames[report.type] ?? report.type}</span></td>
                    <td>{report.description}</td>
                    <td>{report.lat.toFixed(4)}, {report.lng.toFixed(4)}</td>
                    <td>{report.severity}</td>
                    <td>+{report.votes_confirm} / −{report.votes_deny}</td>
                    <td>{report.status}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>
      <footer>KinNav · Console de supervision MVP · Données de démonstration non persistées</footer>
    </main>
  );
}
