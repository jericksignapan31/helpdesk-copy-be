import { GeminiService } from './gemini.service';

describe('GeminiService conversational fallback', () => {
  function createUnavailableService() {
    return new GeminiService({
      get: jest.fn().mockReturnValue(undefined),
    } as any);
  }

  it('classifies a simple help request as general conversation', async () => {
    const service = createUnavailableService();

    await expect(service.detectIntent('can you help me')).resolves.toEqual({
      intent: 'GENERAL',
      confidence: 0.85,
    });
  });

  it('responds naturally to a help request when Gemini is unavailable', async () => {
    const service = createUnavailableService();

    const response = await service.generateResponse('can you help me');

    expect(response.text).toBe(
      'Of course! What can I help you with? Tell me about the IT issue or question you have.',
    );
    expect(response.confidence).toBe(0.85);
  });

  it('responds in Filipino to a simple Filipino help request', async () => {
    const service = createUnavailableService();

    const response = await service.generateResponse(
      'pwede mo ba akong tulungan',
    );

    expect(response.text).toContain('Oo naman!');
  });

  it('uses a natural Filipino fallback for a Filipino IT question', async () => {
    const service = createUnavailableService();

    const response = await service.generateResponse(
      'Paano ko maaayos ang problema ko?',
    );

    expect(response.text).toContain('Wala pa akong sapat na kumpirmadong impormasyon');
    expect(response.text).not.toContain('I do not have enough');
  });

  it('keeps verified system facts focused on the user question', async () => {
    const service = createUnavailableService();

    const response = await service.generateResponse(
      'Paano gumagana ang password change?',
      {
        systemKnowledge: [
          {
            topic: 'Password change',
            source: 'auth',
            facts: ['Kailangan ang kasalukuyang password para magpalit.'],
          },
        ],
      },
    );

    expect(response.text).toContain(
      'Kailangan ang kasalukuyang password para magpalit.',
    );
    expect(response.text).not.toContain('contact your IT administrator');
  });
});
