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

  it('answers who the bot is when Gemini is unavailable', async () => {
    const service = createUnavailableService();

    await expect(
      service.detectIntent('hello who are you?'),
    ).resolves.toEqual({
      intent: 'GENERAL',
      confidence: 0.85,
    });

    const response = await service.generateResponse('hello who are you?');
    expect(response.text).toContain("I'm the IT Help Desk Bot.");
  });

  it('answers identity questions in Filipino when Gemini is unavailable', async () => {
    const service = createUnavailableService();

    const response = await service.generateResponse('Sino ka?');

    expect(response.text).toContain('Ako ang IT Help Desk Bot.');
  });

  it('responds in Filipino to a simple Filipino help request', async () => {
    const service = createUnavailableService();

    const response = await service.generateResponse(
      'pwede mo ba akong tulungan',
    );

    expect(response.text).toContain('Oo naman!');
  });

  it('classifies Filipino how-to questions as FAQs without Gemini', async () => {
    const service = createUnavailableService();

    await expect(
      service.detectIntent('Paano ako makakakonekta sa WiFi?'),
    ).resolves.toEqual({
      intent: 'FAQ',
      confidence: 0.6,
    });
  });

  it('classifies Filipino device failures as troubleshooting without Gemini', async () => {
    const service = createUnavailableService();

    await expect(
      service.detectIntent('Hindi gumagana ang printer ko'),
    ).resolves.toEqual({
      intent: 'TROUBLESHOOTING',
      confidence: 0.65,
    });
  });

  it('classifies Filipino ticket requests without Gemini', async () => {
    const service = createUnavailableService();

    await expect(
      service.detectIntent('Pwede mo ba akong gawan ng ticket?'),
    ).resolves.toEqual({
      intent: 'TICKET_CREATION',
      confidence: 0.65,
    });
  });

  it('retries a transient Gemini 503 and returns the generated answer', async () => {
    jest.useFakeTimers();
    try {
      const service = createUnavailableService();
      const generateContent = jest
        .fn()
        .mockRejectedValueOnce({ status: 503 })
        .mockResolvedValueOnce({
          response: {
            text: () => 'Kumusta! Ano ang maitutulong ko?',
            usageMetadata: {},
          },
        });
      (service as any).isAvailable = true;
      (service as any).model = { generateContent };

      const responsePromise = service.generateResponse('hello');
      await jest.advanceTimersByTimeAsync(2000);
      const response = await responsePromise;

      expect(generateContent).toHaveBeenCalledTimes(2);
      expect(response.text).toBe('Kumusta! Ano ang maitutulong ko?');
    } finally {
      jest.useRealTimers();
    }
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
