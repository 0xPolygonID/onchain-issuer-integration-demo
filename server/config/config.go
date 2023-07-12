package config

import (
	"errors"
	"log"
	"os"

	"github.com/kelseyhightower/envconfig"
	"gopkg.in/yaml.v3"
)

type resolverSettings map[string]struct {
	NetworkURL    string `yaml:"networkURL"`
	ContractState string `yaml:"contractState"`
}

func (r resolverSettings) Verify() error {
	for _, settings := range r {
		if settings.NetworkURL == "" {
			return errors.New("network url is not set")
		}
		if settings.ContractState == "" {
			return errors.New("contract state is not set")
		}
	}
	return nil
}

type Config struct {
	OnchainIssuerIdentity string `envconfig:"ONCHAIN_ISSUER_IDENTITY"`
	KeyDir                string `envconfig:"KEY_DIR" default:"./keys"`
	HostUrl               string `envconfig:"HOST_URL"`
	Resolvers             resolverSettings
}

func readResolverConfig(cfg *Config) error {
	content, err := os.ReadFile("resolvers.settings.yaml")
	if err != nil {
		return err
	}
	var settings resolverSettings
	if err = yaml.Unmarshal(content, &settings); err != nil {
		return err
	}
	if err = settings.Verify(); err != nil {
		return err
	}
	cfg.Resolvers = settings
	return nil
}

func ParseConfig() (Config, error) {
	var cfg Config
	if err := envconfig.Process("", &cfg); err != nil {
		log.Fatal("failed read config", err)
	}
	if err := readResolverConfig(&cfg); err != nil {
		return cfg, err
	}
	if err := cfg.Resolvers.Verify(); err != nil {
		return cfg, err
	}
	return cfg, nil
}
